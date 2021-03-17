module Transactions
  class Authorize < ::Transaction
    enum status: [:pending, :approved, :captured, :error]
  end
end
