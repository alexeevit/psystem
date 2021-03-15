class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, presence: true, on: :create
end
