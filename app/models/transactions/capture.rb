module Transactions
  class Capture < ::Transaction
    enum status: [:approved, :refunded, :error]

    scope :successful, -> { where.not(status: :error) }
  end
end
