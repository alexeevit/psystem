require "rails_helper"

describe User, type: :model do
  describe "Validations" do
    subject(:user) { build(:admin) }

    describe "#email" do
      it "is required" do
        user.email = nil
        expect(user).to be_invalid
        expect(user.errors[:email].size).to be > 1
      end

      it "matches email mask" do
        user.email = "random"
        expect(user).to be_invalid
        expect(user.errors[:email].size).to eq(1)
      end
    end

    describe "#password" do
      it "is required" do
        user.password = nil
        expect(user.valid?(:create)).to be_falsey
        expect(user.errors[:password].size).to eq(1)
      end
    end
  end
end
