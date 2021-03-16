module Transactions
  class Refund < ::Transaction
    def type_name
      "refund".freeze
    end
  end
end
