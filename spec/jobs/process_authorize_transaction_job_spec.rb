require "rails_helper"

describe ProcessAuthorizeTransactionJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :test }

  describe "#perform" do
    let(:authorize) { create(:authorize, status: status) }
    let(:status) { :pending }

    context "when transaction is not pending" do
      let(:status) { :error }

      it "does not call service" do
        expect_any_instance_of(ProcessAuthorizeTransactionService).not_to receive(:call)
        described_class.perform_now(authorize)
      end
    end

    context "when service approves the transaction" do
      before do
        allow_any_instance_of(described_class).to receive(:authorization_service).and_return(proc { true })
      end

      it "makes the transaction approved and schedules webhook job" do
        expect {
          described_class.perform_now(authorize)
        }.to change(authorize, :status).from("pending").to("approved")
        expect(SendAuthorizeWebhookJob).to have_been_enqueued
      end
    end

    context "when service declines the transaction" do
      before do
        allow_any_instance_of(described_class).to receive(:authorization_service).and_return(proc { false })
      end

      it "makes the transaction declined and schedules webhook job" do
        expect {
          described_class.perform_now(authorize)
        }.to change(authorize, :status).from("pending").to("declined")
        expect(SendAuthorizeWebhookJob).to have_been_enqueued
      end
    end
  end
end
