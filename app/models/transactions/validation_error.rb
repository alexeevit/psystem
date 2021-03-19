class Transactions::ValidationError < Transactions::StandardError
  attr_reader :errors

  def initialize(errors = {}, msg = "Some parameters are invalid")
    @errors = errors
    super(msg)
  end

  def error_messages
    errors.map { |k, ke| ke.map { |e| "#{k} #{e}" } }.flatten
  end
end
