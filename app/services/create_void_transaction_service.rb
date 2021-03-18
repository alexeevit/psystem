class CreateVoidTransactionService < ApplicationService
  VALID_AUTHORIZE_STATUSES = [:approved].freeze

  attr_reader :authorize, :errors

  def initialize(authorize)
    @authorize = authorize
    @errors = {}
  end

  def call
    validate_params

    status = errors.any? ? :error : :approved
    transaction = Transactions::Void.create!(
      status: status,
      account: authorize.account,
      uuid: authorize.uuid,
      unique_id: SecureRandom.uuid
    )

    if errors.any?
      transaction.make_error!(errors)
      raise Transactions::ValidationError, errors
    end

    make_authorize_voided
    transaction
  end

  private

  def validate_params
    validate_authorize_status
  end

  def validate_authorize_status
    errors[:authorize_status] = ["is \"#{authorize.status}\""] unless authorize.status.to_sym.in?(VALID_AUTHORIZE_STATUSES)
  end

  def make_authorize_voided
    authorize.update!(status: :voided)
  end
end
