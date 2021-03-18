class CreateTransactionService < ApplicationService
  attr_reader :transaction_class, :account, :params

  def initialize(type, account, params)
    @transaction_class = Transaction.type_by_name(type)
    raise ArgumentError, "Type has invalid value" unless transaction_class

    @account = account
    raise ArgumentError, "Account has invalid type" unless account.is_a?(Account)

    begin
      @params = Hash(params).symbolize_keys
    rescue TypeError
      raise ArgumentError, "Params is not a Hash"
    end
  end

  def call
    return create_authorize_transaction(account, params) if authorize?

    authorize_transaction = Transactions::Authorize.find_by(unique_id: params.fetch(:unique_id), account_id: account.id)
    raise Transactions::AuthorizeNotFoundError unless authorize_transaction

    create_related_transaction(authorize_transaction, params)
  end

  private

  def create_authorize_transaction(account, params)
    transaction = CreateAuthorizeTransactionService.call(account, params)
    ProcessAuthorizeTransactionJob.perform_later(transaction)
    transaction
  end

  def create_related_transaction(authorize, params)
    return CreateCaptureTransactionService.call(authorize, params) if capture?
    return CreateRefundTransactionService.call(authorize, params) if refund?
    return CreateVoidTransactionService.call(authorize) if void?
    raise NotImplementedError, "The method to create this transaction type is not implemented yet"
  end

  Transactions::TypeNames::TYPES.each do |name, klass|
    method_name = "#{name}?"

    define_method(method_name) do
      transaction_class == klass
    end

    private method_name
  end
end
