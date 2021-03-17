module Transactions
  class Refund < ::Transaction
    enum status: [:error, :approved]
  end
end
