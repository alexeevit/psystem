require "rails_helper"

describe CreateVoidTransactionService do
  subject(:service) { described_class.new(authorize) }
  let(:authorize) { create(:authorize, amount: 100, status: status) }
  let(:status) { :approved }

  describe "#call" do
    context "when all params are valid" do
      it "creates the approved transaction and returns it" do
        expect {
          new_transaction = service.call
          expect(new_transaction).to be_instance_of(Transactions::Void)
          expect(new_transaction.status).to eq("approved")
          expect(new_transaction.uuid).to eq(authorize.uuid)
          expect(new_transaction.amount).to be_nil
          expect(new_transaction.unique_id).to be_instance_of(String)
        }.to change(Transactions::Void, :count).by(1)
      end

      it "makes the authorize transaction voided" do
        expect { service.call }.to change(authorize, :status).from("approved").to("voided")
      end
    end

    context "when some params are invalid" do
      let(:status) { :captured }

      it "creates the transaction with error status and raises ValidationError" do
        expect {
          new_transaction = service.call
          expect(new_transaction).to be_instance_of(Transactions::Void)
          expect(new_transaction.status).to eq("error")
          expect(new_transaction.validation_errors).to include({authorize_status: ["is \"captured\""]})
          expect(new_transaction.amount).to be_nil
          expect(new_transaction.uuid).to eq(authorize.uuid)
          expect(new_transaction.unique_id).to be_instance_of(String)
        }.to change(Transactions::Void, :count).by(1)
          .and raise_error(Transactions::ValidationError, "Some parameters are invalid")
      end
    end
  end

  describe "Validations" do
    subject(:errors) { service.errors }

    describe "#validate_params" do
      it "runs all validation methods" do
        expect(service).to receive(:validate_authorize_status)
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

      context "when authorize status is not approved" do
        let(:status) { :captured }

        it "adds an error" do
          service.send(:validate_authorize_status)
          expect(errors[:authorize_status]).to include("is \"captured\"")
        end
      end
    end
  end
end
