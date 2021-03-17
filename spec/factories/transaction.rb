FactoryBot.define do
  factory :authorize, class: "Transactions::Authorize" do
    unique_id { SecureRandom.uuid }
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end

  factory :capture, class: "Transactions::Capture" do
    unique_id { SecureRandom.uuid }
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end

  factory :refund, class: "Transactions::Refund" do
    unique_id { SecureRandom.uuid }
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end

  factory :void, class: "Transactions::Void" do
    unique_id { SecureRandom.uuid }
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end
end
