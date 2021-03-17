class Transactions::ValidationError < StandardError
  attr_reader :errors

  def initialize(errors = {}, msg = "Some parameters are invalid")
    @errors = errors
    super(msg)
  end
end
