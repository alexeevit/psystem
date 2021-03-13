FactoryBot.define do
  factory :transaction do
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end
end
