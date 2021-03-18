require "rails_helper"

describe Transactions::Void, type: :model do
  subject(:void) { build(:void) }

  describe "#type_name" do
    it { expect(void.type_name).to eq(:void) }
  end
end
