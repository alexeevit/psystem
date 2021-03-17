require "rails_helper"

describe CreateCaptureTransactionService do
  subject(:service) { described_class.new(authorize, params) }
  let(:authorize) { create(:authorize, amount: 100, status: status) }
  let(:status) { :approved }
  let(:params) do
    {amount: 100}
  end

  describe "#call" do
    context "when all params are valid" do
      it "creates the approved transaction and returns it" do
        expect {
          new_transaction = service.call
          expect(new_transaction).to be_instance_of(Transactions::Capture)
          expect(new_transaction.status).to eq("approved")
          expect(new_transaction.uuid).to eq(authorize.uuid)
          expect(new_transaction.amount).to eq(params[:amount])
          expect(new_transaction.unique_id).to be_instance_of(String)
        }.to change(Transactions::Capture, :count).by(1)
      end

      it "makes the authorize transaction captured" do
        expect { service.call }.to change(authorize, :status).from("approved").to("captured")
      end
    end

    context "when some params are invalid" do
      let(:params) { {amount: -100} }

      it "creates the transaction without invalid params and error status and raises ValidationError" do
        expect {
          new_transaction = service.call
          expect(new_transaction).to be_instance_of(Transactions::Capture)
          expect(new_transaction.status).to eq(:error)
          expect(new_transaction.validation_errors).to include({amount: ["is not positive"]})
          expect(new_transaction.amount).to be_nil
          expect(new_transaction.uuid).to eq(authorize.uuid)
          expect(new_transaction.unique_id).to be_instance_of(String)
        }.to change(Transactions::Capture, :count).by(1)
          .and raise_error(Transactions::ValidationError, "Some parameters are invalid")
      end
    end
  end

  describe "Validations" do
    subject(:errors) { service.errors }

    describe "#validate_params" do
      it "runs all validation methods" do
        expect(service).to receive(:validate_authorize_status)
        expect(service).to receive(:validate_amount)
        expect(service).to receive(:validate_captured_amount)

        service.send(:validate_params)
      end
    end

    describe "#validate_authorize_status" do
      context "when authorize status is approved" do
        it "leaves errors blank" do
          service.send(:validate_authorize_status)
          expect(errors[:authorize_status]).to be_blank
        end
      end

      context "when authorize status is captured" do
        let(:status) { :captured }

        it "leaves errors blank" do
          service.send(:validate_authorize_status)
          expect(errors[:authorize_status]).to be_blank
        end
      end

      context "when authorize status is not approved or captured" do
        let(:status) { :error }

        it "adds an error" do
          service.send(:validate_authorize_status)
          expect(errors[:authorize_status]).to include("is \"error\"")
        end
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

    describe "#validate_captured_amount" do
      context "when there are no other capture transactions" do
        it "leaves errors blank if less than or equal to authorized amount" do
          service.send(:validate_captured_amount)
          expect(errors[:authorize_status]).to be_blank
        end

        it "adds an error if greater than authorized amount" do
          params[:amount] = 101
          service.send(:validate_captured_amount)
          expect(errors[:amount]).to include("exceeds the authorized amount")
        end
      end

      context "when there are existed capture transactions" do
        before do
          # successful amount sum 90
          3.times { create(:capture, status: :approved, uuid: authorize.uuid, amount: 30) }
          create(:capture, status: :error, uuid: authorize.uuid, amount: 30)
        end

        it "leaves errors blank if sum is less than or equal to authorized amound" do
          params[:amount] = 10
          service.send(:validate_captured_amount)
          expect(errors[:authorize_status]).to be_blank
        end

        it "adds an error if sum is greater than authorized amount" do
          params[:amount] = 11
          service.send(:validate_captured_amount)
          expect(errors[:amount]).to include("exceeds the authorized amount")
        end
      end
    end
  end
end
