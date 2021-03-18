class CreateRefundTransactionService < ApplicationService
  include CommonValidations

  VALID_CAPTURE_STATUSES = [:approved, :refunded].freeze

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
    transaction = Transactions::Refund.create!(permitted_params.merge({
      status: status,
      account: authorize.account,
      uuid: authorize.uuid,
      unique_id: SecureRandom.uuid
    }))

    if errors.any?
      transaction.make_error!(errors)
      raise Transactions::ValidationError, errors
    end

    make_captures_refunded
    transaction
  end

  private

  def permitted_params
    params.slice(:amount)
  end

  def validate_params
    validate_amount
    validate_refunded_amount
  end

  def validate_refunded_amount
    captured_amount = authorize.capture_transactions.successful.sum(:amount)
    refunded_amount = authorize.refund_transactions.successful.sum(:amount) + Integer(params[:amount])

    if refunded_amount > captured_amount
      errors[:amount] ||= []
      errors[:amount] << "exceeds the captured amount"
    end
  end

  def make_captures_refunded
    return if authorize.capture_transactions.pluck(:status).uniq == [:refunded]
    authorize.capture_transactions.each(&:make_refunded!)
  end
end
