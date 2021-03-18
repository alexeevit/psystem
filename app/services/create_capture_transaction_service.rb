class CreateCaptureTransactionService < ApplicationService
  include CommonValidations

  VALID_AUTHORIZE_STATUSES = [:approved, :captured].freeze

  attr_reader :authorize, :params, :errors

  def initialize(authorize, params)
    @authorize = authorize
    @params = params
    @errors = {}
  end

  def call
    validate_params
    clean_invalid_params

    status = errors.any? ? :error : :approved
    transaction = Transactions::Capture.create!(permitted_params.merge({
      status: status,
      account: authorize.account,
      uuid: authorize.uuid,
      unique_id: SecureRandom.uuid
    }))

    if errors.any?
      transaction.make_error!(errors)
      raise Transactions::ValidationError, errors
    end

    make_authorize_captured
    transaction
  end

  private

  def permitted_params
    params.slice(:amount)
  end

  def validate_params
    validate_authorize_status
    validate_amount
    validate_captured_amount
  end

  def validate_authorize_status
    errors[:authorize_status] = ["is \"#{authorize.status}\""] unless authorize.status.to_sym.in?(VALID_AUTHORIZE_STATUSES)
  end

  def validate_captured_amount
    return if errors[:amount]
    is_greater = authorize.capture_transactions.successful.sum(:amount) + Integer(params[:amount]) > authorize.amount

    if is_greater
      errors[:amount] ||= []
      errors[:amount] << "exceeds the authorized amount"
    end
  end

  def make_authorize_captured
    authorize.update!(status: :captured) unless authorize.captured?
  end
end
