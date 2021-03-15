class Merchant < User
  enum status: {active: "active", inactive: "inactive"}
  has_one :account

  validates :status, presence: true, inclusion: {in: ["active", "inactive"]}
end
