module Transactions
  class Capture < ::Transaction
    enum status: [:error, :approved, :refunded]

    scope :successful, -> { where.not(status: :error) }

    def make_refunded!
      update!(status: :refunded)
    end
  end
end
