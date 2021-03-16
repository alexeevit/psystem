module Transactions
  class Capture < ::Transaction
    def type_name
      "capture".freeze
    end
  end
end
