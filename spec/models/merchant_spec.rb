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

  describe "Callbacks" do
    subject!(:merchant) { create(:merchant) }

    describe "#check_transactions" do
      context "when there no transactions" do
        it "allows to destroy merchant" do
          expect {
            merchant.destroy
          }.to change(Merchant, :count).by(-1)
        end
      end

      context "when there are transactions" do
        before { create(:authorize, account: merchant.account) }

        it "does not allow to destroy merchant" do
          expect {
            merchant.destroy
          }.not_to change(Merchant, :count)
        end
      end
    end
  end
end
