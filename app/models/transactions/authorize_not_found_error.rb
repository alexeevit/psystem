class Transactions::AuthorizeNotFoundError < Transactions::StandardError
  def initialize(msg = "invalid unique_id")
    super(msg)
  end
end
