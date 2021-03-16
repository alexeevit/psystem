module Transactions
  class Authorize < ::Transaction
    def type_name
      "authorize".freeze
    end
  end
end
