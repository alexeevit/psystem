module Transactions
  class Refund < ::Transaction
    enum status: [:error, :approved]

    scope :successful, -> { where.not(status: :error) }
  end
end
