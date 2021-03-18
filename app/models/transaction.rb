class Transaction < ApplicationRecord
  validates :uuid, presence: true
  validates :unique_id, presence: true

  belongs_to :account

  class << self
    def type_by_name(name)
      Transactions::TypeNames::TYPES[name.to_sym]
    end

    def name_by_type(type)
      Transactions::TypeNames::TYPE_NAMES[type]
    end

    def type_name
      name_by_type(self)
    end
  end

  def type_name
    self.class.type_name
  end

  def make_error!(errors)
    update!(status: :error, validation_errors: errors)
  end
end
