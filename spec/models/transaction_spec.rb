require "rails_helper"

describe Transaction, type: :model do
  describe "Validations" do
    subject(:transaction) { build(:transaction) }

    describe "#uuid" do
      it "is required" do
        transaction.uuid = nil
        expect(transaction).to be_invalid
        expect(transaction.errors[:uuid].size).to eq(1)
      end
    end

    describe "#amount" do
      it "is required" do
        transaction.amount = nil
        expect(transaction).to be_invalid
        expect(transaction.errors[:amount].size).to be > 1
      end

      it "is greater than zero" do
        transaction.amount = 0
        expect(transaction).to be_invalid
        expect(transaction.errors[:amount].size).to eq(1)
      end
    end
  end
end
