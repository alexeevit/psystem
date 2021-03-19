class Merchant < User
  enum status: [:inactive, :active]
  has_one :account, dependent: :destroy

  validates :status, presence: true, inclusion: {in: ["active", "inactive"]}

  after_create :create_account

  private

  def create_account
    return if account.present?
    self.account = Account.create!(merchant: self)
  end
end
