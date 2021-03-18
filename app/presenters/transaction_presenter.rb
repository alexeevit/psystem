class TransactionPresenter < ApplicationPresenter
  def data
    model.attributes.symbolize_keys.slice(:unique_id, :status, :amount, :notification_url, :customer_email, :customer_phone)
  end
end
