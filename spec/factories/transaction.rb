FactoryBot.define do
  factory :authorize, class: "Transactions::Authorize" do
    auth_code { SecureRandom.uuid }
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end

  factory :capture, class: "Transactions::Capture" do
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end

  factory :refund, class: "Transactions::Refund" do
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end

  factory :void, class: "Transactions::Void" do
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end
end
