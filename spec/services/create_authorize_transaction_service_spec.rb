require "rails_helper"

describe CreateAuthorizeTransactionService do
  subject(:service) { CreateAuthorizeTransactionService.new(account, params) }
  let(:account) { create(:account) }
  let(:params) do
    {
      amount: 100,
      notification_url: "https://google.com/psystem_webhook",
      customer_email: "johnbowie@gmail.com",
      customer_phone: "+79999999999"
    }
  end

  describe "#call" do
    context "when all params are valid" do
      it "creates the transaction with status pending and returns it" do
        expect {
          new_transaction = service.call
          expect(new_transaction).to be_instance_of(Transactions::Authorize)
          expect(new_transaction.status).to eq("pending")
          expect(new_transaction.attributes).to include(params.stringify_keys)
          expect(new_transaction.uuid).to be_instance_of(String)
          expect(new_transaction.unique_id).to be_instance_of(String)
        }.to change(Transactions::Authorize, :count).by(1)
      end
    end

    context "when some params are invalid" do
      let(:params) { {amount: -100} }

      it "creates the transaction without invalid params and error status and raises ValidationError" do
        expect {
          new_transaction = service.call
          expect(new_transaction).to be_instance_of(Transactions::Authorize)
          expect(new_transaction.status).to eq(:error)
          expect(new_transaction.validation_errors).to include({amount: ["is not positive"]})
          expect(new_transaction.amount).to be_nil
          expect(new_transaction.attributes).to include(params.except(:amount))
          expect(new_transaction.uuid).to be_instance_of(String)
          expect(new_transaction.unique_id).to be_instance_of(String)
        }.to change(Transactions::Authorize, :count).by(1)
          .and raise_error(Transactions::ValidationError)
      end
    end
  end

  describe "Validations" do
    subject(:errors) { service.errors }

    describe "#validate_params" do
      it "runs all validation methods" do
        expect(service).to receive(:validate_amount)
        expect(service).to receive(:validate_notification_url)
        expect(service).to receive(:validate_customer_email)

        service.send(:validate_params)
      end
    end

    describe "#validate_amount" do
      it "leaves errors blank if valid" do
        service.send(:validate_amount)
        expect(errors[:amount]).to be_blank
      end

      it "adds an error if blank" do
        params.delete(:amount)
        service.send(:validate_amount)
        expect(errors[:amount]).to include("is blank")
      end

      it "adds an error if zero" do
        params[:amount] = 0
        service.send(:validate_amount)
        expect(errors[:amount]).to include("is not positive")
      end

      it "adds an error if less than zero" do
        params[:amount] = -15
        service.send(:validate_amount)
        expect(errors[:amount]).to include("is not positive")
      end

      it "adds an error if non-integer" do
        params[:amount] = "hello!"
        service.send(:validate_amount)
        expect(errors[:amount]).to include("has non-integer value")
      end
    end

    describe "#validate_notification_url" do
      it "leaves errors blank if valid" do
        service.send(:validate_notification_url)
        expect(errors[:notification_url]).to be_blank
      end

      it "adds an error if blank" do
        params.delete(:notification_url)
        service.send(:validate_notification_url)
        expect(errors[:notification_url]).to include("is blank")
      end

      it "adds an error if non-url format" do
        params[:notification_url] = "non-url format"
        service.send(:validate_notification_url)
        expect(errors[:notification_url]).to include("is invalid url")
      end

      it "adds an error if invalid scheme" do
        params[:notification_url] = "sftp://hello.world"
        service.send(:validate_notification_url)
        expect(errors[:notification_url]).to include("has invalid scheme")
      end
    end

    describe "#validate_customer_email" do
      it "leaves errors blank if valid" do
        service.send(:validate_customer_email)
        expect(errors[:customer_email]).to be_blank
      end

      it "adds an error if blank" do
        params.delete(:customer_email)
        service.send(:validate_customer_email)
        expect(errors[:customer_email]).to include("is blank")
      end

      it "adds an error if non-email format" do
        params[:customer_email] = "invalid email"
        service.send(:validate_customer_email)
        expect(errors[:customer_email]).to include("is invalid email")
      end
    end
  end
end
