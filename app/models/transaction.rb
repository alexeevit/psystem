class Transaction < ApplicationRecord
  validates :uuid, presence: true
  validates :amount, presence: true, numericality: {greater_than: 0}

  belongs_to :account
end
