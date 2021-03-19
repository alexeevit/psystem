class Transactions::InactiveMerchantError < Transactions::StandardError
  def initialize(msg = "inactive merchant")
    super(msg)
  end

  def http_status
    403
  end
end
