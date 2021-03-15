require "rails_helper"

describe Merchant, type: :model do
  describe "Validations" do
    subject(:merchant) { build(:merchant) }

    describe "#status" do
      it "is required" do
        merchant.status = nil
        expect(merchant).to be_invalid
        expect(merchant.errors[:status].size).to be > 1
      end
    end
  end
end
