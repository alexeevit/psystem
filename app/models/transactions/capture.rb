module Transactions
  class Capture < ::Transaction
    enum status: [:error, :approved, :refunded]

    scope :successful, -> { where.not(status: :error) }
  end
end
