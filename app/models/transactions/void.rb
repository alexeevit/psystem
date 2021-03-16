module Transactions
  class Void < ::Transaction
    def type_name
      "void".freeze
    end
  end
end
