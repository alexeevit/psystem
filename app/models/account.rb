class Account < ApplicationRecord
  belongs_to :merchant
  has_many :transactions, dependent: :restrict_with_error

  validates :merchant, presence: true
end
