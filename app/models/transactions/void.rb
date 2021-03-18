module Transactions
  class Void < ::Transaction
    enum status: [:error, :approved]
  end
end
