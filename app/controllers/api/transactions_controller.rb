class Api::TransactionsController < Api::ApplicationController
  def index
    respond_to do |format|
      format.json {}
      format.xml {}
    end
  end
end
