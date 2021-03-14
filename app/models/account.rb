class Account < ApplicationRecord
  belongs_to :merchant

  validates :merchant, presence: true
end
