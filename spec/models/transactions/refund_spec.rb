require "rails_helper"

describe Transactions::Refund, type: :model do
  subject(:refund) { build(:refund) }

  describe "#type_name" do
    it { expect(refund.type_name).to eq("refund") }
  end
end
