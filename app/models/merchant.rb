class Merchant < User
  enum status: [:inactive, :active]
  has_one :account

  validates :status, presence: true, inclusion: {in: ["active", "inactive"]}
end
