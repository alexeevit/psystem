class CreateAuthorizeTransactionService < ApplicationService
  attr_reader :account, :params, :errors

  def initialize(account, params)
    @account = account
    @params = params
    @errors = {}
  end

  def call
    validate_params
    clean_invalid_params

    transaction = Transactions::Authorize.create!(permitted_params.merge({
      status: :pending,
      account: account,
      uuid: SecureRandom.uuid,
      unique_id: SecureRandom.uuid
    }))

    if errors.any?
      transaction.make_error!(errors)
      raise Transactions::ValidationError, errors
    end

    ProcessAuthorizeTransactionJob.perform_later(transaction: transaction)

    transaction
  end

  private

  def permitted_params
    params.slice(:amount, :notification_url, :customer_email, :customer_phone)
  end

  def validate_params
    validate_amount
    validate_notification_url
    validate_customer_email
  end

  def validate_amount
    (errors[:amount] = ["is blank"]) && return if params[:amount].blank?

    amount = Integer(params[:amount])
    (errors[:amount] = ["is not positive"]) && return if amount <= 0
  rescue TypeError, ArgumentError
    errors[:amount] = ["has non-integer value"]
  end

  def validate_notification_url
    url = URI.parse(String(params[:notification_url]))
    (errors[:notification_url] = ["is blank"]) && return if url.host.blank?
    errors[:notification_url] = ["has invalid scheme"] unless url.scheme.in?(["http", "https"])
  rescue URI::InvalidURIError
    errors[:notification_url] = ["is invalid url"]
  end

  def validate_customer_email
    email = String(params[:customer_email])

    (errors[:customer_email] = ["is blank"]) && return if email.blank?
    errors[:customer_email] = ["is invalid email"] unless email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def clean_invalid_params
    errors.keys.each do |key|
      params.delete(key)
    end
  end
end
