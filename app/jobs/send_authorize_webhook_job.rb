class SendAuthorizeWebhookJob < ApplicationJob
  queue_as :default

  MAX_ATTEMPTS_COUNT = 5

  class FailedRequest < ::StandardError
  end

  retry_on StandardError, wait: 5.minutes, attempts: 10

  def perform(transaction)
    return unless transaction.approved? || transaction.declined?

    response = send_request(
      url: transaction.notification_url,
      status: transaction.status,
      amount: transaction.amount,
      unique_id: transaction.unique_id
    )

    raise FailedRequest unless response.success?

    update_transaction_on_success(transaction)
  rescue FailedRequest
    if transaction.notification_attempts >= MAX_ATTEMPTS_COUNT
      stop_transaction_notifications(transaction)
    else
      update_last_notification_at(transaction)
      self.class.set(wait: 5.minutes).perform_later(transaction)
    end
  end

  private

  def send_request(url:, status:, amount:, unique_id:)
    Faraday.post(url, {unique_id: unique_id, status: status, amount: amount})
  end

  def update_transaction_on_success(transaction)
    transaction.update!(notification: :successful, last_notification_at: DateTime.current)
  end

  def update_last_notification_at(transaction)
    transaction.update!(last_notification_at: DateTime.current, notification_attempts: transaction.notification_attempts + 1)
  end

  def stop_transaction_notifications(transaction)
    transaction.update!(notification: :failed, last_notification_at: DateTime.current)
  end
end
