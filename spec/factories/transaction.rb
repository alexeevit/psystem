FactoryBot.define do
  factory :authorize, class: "Transactions::Authorize" do
    status { :approved }
    unique_id { SecureRandom.uuid }
    uuid { SecureRandom.uuid }
    amount { 100 }
    notification { :pending }
    account
  end

  factory :capture, class: "Transactions::Capture" do
    status { :approved }
    unique_id { SecureRandom.uuid }
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end

  factory :refund, class: "Transactions::Refund" do
    status { :approved }
    unique_id { SecureRandom.uuid }
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end

  factory :void, class: "Transactions::Void" do
    status { :approved }
    unique_id { SecureRandom.uuid }
    uuid { SecureRandom.uuid }
    amount { 100 }
    account
  end
end
