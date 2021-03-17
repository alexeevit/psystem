module Transactions
  class Authorize < ::Transaction
    enum status: [:pending, :approved, :captured, :error]

    has_many :capture_transactions, class_name: "Transactions::Capture", foreign_key: :uuid, primary_key: :uuid
  end
end
