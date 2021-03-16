class Admin::TransactionsController < Admin::ApplicationController
  def index
    @transactions = Transaction.order(created_at: :desc).all
  end
end
