require "rails_helper"

describe Transactions::Authorize, type: :model do
  subject(:authorize) { build(:authorize) }

  describe "#type_name" do
    it { expect(authorize.type_name).to eq(:authorize) }
  end
end
