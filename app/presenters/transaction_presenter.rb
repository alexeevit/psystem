class TransactionPresenter < ApplicationPresenter
  def data
    model.attributes.slice("unique_id", "status", "amount", "notification_url", "customer_email", "customer_phone").merge({
      "type" => type,
      "created_at" => created_at
    })
  end

  def type
    String(model.type_name)
  end

  def created_at
    model.created_at.utc.to_i
  end
end
