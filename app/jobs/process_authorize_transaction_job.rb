class ProcessAuthorizeTransactionJob < ApplicationJob
  queue_as :default

  def perform(transaction)
    return unless transaction.pending?

    if authorization_service(transaction).call
      transaction.update!(status: :approved)
    else
      transaction.update!(status: :declined)
    end

    SendAuthorizeWebhookJob.perform_later(transaction)
  end

  private

  def authorization_service(transaction)
    ProcessAuthorizeTransactionService.new(transaction)
  end
end
