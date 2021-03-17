module Transactions
  class Authorize < ::Transaction
    enum status: [:error, :pending, :approved, :captured, :voided]

    has_many :capture_transactions, class_name: "Transactions::Capture", foreign_key: :uuid, primary_key: :uuid
  end
end
