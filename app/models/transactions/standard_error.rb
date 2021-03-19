class Transactions::StandardError < StandardError
  attr_reader :msg

  def initialize(msg)
    @msg = msg
  end

  def error_messages
    [msg]
  end

  def http_status
    422
  end
end
