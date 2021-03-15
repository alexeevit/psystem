FactoryBot.define do
  sequence :merchant_email do |n|
    "merchant#{n}@example.com"
  end

  sequence :admin_email do |n|
    "admin#{n}@example.com"
  end

  factory :merchant do
    status { :active }
    email { generate(:merchant_email) }
    password { "password" }
    name { "Mike" }
    description { "A regular merchant" }
  end

  factory :admin do
    email { generate(:admin_email) }
    password { "password" }
    name { "Bill" }
    description { "A regular admin" }
  end
end
