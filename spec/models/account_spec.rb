require "rails_helper"

describe Account, type: :model do
  describe "Validations" do
    subject(:account) { build(:account) }

    describe "#merchant" do
      it "is required" do
        account.merchant = nil
        expect(account).to be_invalid
        expect(account.errors[:merchant].size).to be > 1
      end
    end
  end
end
