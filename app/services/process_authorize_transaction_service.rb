# a fake service that pretends to make a request
# to hold the required amount on the customer's account
class ProcessAuthorizeTransactionService < ApplicationService
  def initialize(_account)
  end

  def call
    [true, false].sample
  end
end
