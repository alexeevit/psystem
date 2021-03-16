require "rails_helper"

describe Transactions::Capture, type: :model do
  subject(:capture) { build(:capture) }

  describe "#type_name" do
    it { expect(capture.type_name).to eq("capture") }
  end
end
