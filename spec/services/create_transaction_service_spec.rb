require "rails_helper"

describe CreateTransactionService do
  before { ActiveJob::Base.queue_adapter = :test }

  let(:type) { :authorize }
  let(:account) { create(:account) }
  let(:authorize) { create(:authorize, account: account) }
  let(:params) do
    {
      amount: 100,
      notification_url: "https://google.com/psystem_webhook",
      customer_email: "johnbowie@gmail.com",
      customer_phone: "+79999999999"
    }
  end

  describe "#initialize" do
    context "when all arguments are valid" do
      it "returns a service instance" do
        instance = described_class.new(type, account, params)

        expect(instance).to be_instance_of(described_class)
        expect(instance.transaction_class).to eq(Transactions::Authorize)
        expect(instance.account).to eq(account)
        expect(instance.params).to eq(params)
      end
    end

    context "when type is invalid" do
      let(:type) { :wrong }

      it "raises an ArgumentError" do
        expect {
          described_class.new(type, account, params)
        }.to raise_error(ArgumentError, "Type has invalid value")
      end
    end

    context "when account is not an Account" do
      let(:account) { "invalid account" }

      it "raises an ArgumentError" do
        expect {
          described_class.new(type, account, params)
        }.to raise_error(ArgumentError, "Account has invalid type")
      end
    end

    context "when params are not convertable to Hash" do
      let(:params) { 123 }

      it "raises an ArgumentError" do
        expect {
          described_class.new(type, account, params)
        }.to raise_error(ArgumentError, "Params is not a Hash")
      end
    end
  end

  describe "#call" do
    subject(:service) { described_class.new(type, account, params) }

    context "when authorize transaction" do
      it "creates transaction, schedules to process it, and returns it" do
        expect(service.call).to be_instance_of(Transactions::Authorize)
        expect(ProcessAuthorizeTransactionJob).to have_been_enqueued
      end
    end

    context "when capture transaction" do
      let(:type) { :capture }
      let(:params) do
        {
          amount: 100,
          unique_id: authorize.unique_id
        }
      end

      it "creates transaction and returns it" do
        expect(service.call).to be_instance_of(Transactions::Capture)
      end
    end

    context "when refund transaction" do
      before { create(:capture, uuid: authorize.uuid, amount: 100, account: account) }

      let(:type) { :refund }
      let(:params) do
        {
          amount: 100,
          unique_id: authorize.unique_id
        }
      end

      it "creates transaction and returns it" do
        expect(service.call).to be_instance_of(Transactions::Refund)
      end
    end

    context "when void transaction" do
      let(:type) { :void }
      let(:params) do
        {
          amount: 100,
          unique_id: authorize.unique_id
        }
      end

      it "creates transaction and returns it" do
        expect(service.call).to be_instance_of(Transactions::Void)
      end
    end

    context "when related transaction and unique_id is invalid" do
      let(:type) { :void }
      let(:params) do
        {
          value: 100,
          unique_id: "invalid"
        }
      end

      it "raises ArgumentError" do
        expect { service.call }.to raise_error(ArgumentError, "Invalid unique_id")
      end
    end
  end
end
