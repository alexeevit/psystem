class Account < ApplicationRecord
  belongs_to :merchant
  has_many :transactions

  validates :merchant, presence: true
end
