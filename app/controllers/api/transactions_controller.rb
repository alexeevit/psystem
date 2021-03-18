class Api::TransactionsController < Api::ApplicationController
  def index
    presenters = current_merchant.account.transactions.map { |transaction| TransactionPresenter.new(transaction) }

    respond_to do |format|
      format.json { render json: presenters.map(&:as_json) }
    end
  end

  def create
    if current_merchant.inactive?
      respond_to do |format|
        format.json { render json: {errors: ["inactive merchant"]}, status: 403 }
      end

      return
    end

    type = String(params[:type])

    transaction = service_class.call(type, current_merchant.account, transaction_params)
    transaction_presenter = TransactionPresenter.new(transaction)

    respond_to do |format|
      format.json { render json: transaction_presenter.as_json }
    end
  rescue Transactions::AuthorizeNotFoundError
    respond_to do |format|
      format.json { render json: {errors: ["invalid unique_id"]}, status: 422 }
    end
  rescue Transactions::ValidationError => e
    errors = e.errors.map { |k, ke| ke.map { |e| "#{k} #{e}" } }.flatten

    respond_to do |format|
      format.json { render json: {errors: errors}, status: 422 }
    end
  end

  private

  def transaction_params
    params.permit(:unique_id, :amount, :notification_url, :customer_email, :customer_phone)
  end

  def service_class
    CreateTransactionService
  end
end
