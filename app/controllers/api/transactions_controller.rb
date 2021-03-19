class Api::TransactionsController < Api::ApplicationController
  def index
    presenters = current_merchant.account.transactions.map { |transaction| TransactionPresenter.new(transaction) }

    respond_to do |format|
      format.json { render json: ApplicationPresenter.as_json(presenters) }
      format.xml { render xml: ApplicationPresenter.as_xml(presenters) }
    end
  end

  def create
    raise Transactions::InactiveMerchantError if current_merchant.inactive?

    type = String(rich_params[:type])

    transaction = service_class.call(type, current_merchant.account, transaction_params)
    transaction_presenter = TransactionPresenter.new(transaction)

    respond_to do |format|
      format.json { render json: transaction_presenter.as_json }
      format.xml { render xml: transaction_presenter.as_xml }
    end
  rescue Transactions::StandardError => e
    respond_to do |format|
      format.json { render json: {errors: e.error_messages}, status: e.http_status }
      format.xml { render xml: {errors: e.error_messages}, status: e.http_status }
    end
  end

  private

  def transaction_params
    rich_params.permit(:unique_id, :amount, :notification_url, :customer_email, :customer_phone)
  end

  def service_class
    CreateTransactionService
  end
end
