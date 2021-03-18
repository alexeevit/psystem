require "rails_helper"

describe Transaction, type: :model do
  describe "Validations" do
    subject(:transaction) { build(:authorize) }

    describe "#uuid" do
      it "is required" do
        transaction.uuid = nil
        expect(transaction).to be_invalid
        expect(transaction.errors[:uuid].size).to eq(1)
      end
    end

    describe "#unique_id" do
      it "is required" do
        transaction.unique_id = nil
        expect(transaction).to be_invalid
        expect(transaction.errors[:unique_id].size).to eq(1)
      end
    end
  end
end
