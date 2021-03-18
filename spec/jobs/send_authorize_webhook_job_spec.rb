require "rails_helper"

describe SendAuthorizeWebhookJob, type: :job do
  before do
    ActiveJob::Base.queue_adapter = :test
    Timecop.freeze(DateTime.new(2021, 1, 1, 9, 30, 0))
  end

  after { Timecop.return }

  let(:authorize) { create(:authorize, status: status, notification_url: webhook_url, notification: :pending) }
  let(:status) { :approved }
  let(:webhook_url) { "https://google.com/psystem_webhook" }

  describe "#perform" do
    before { stub_request(:post, webhook_url) }

    context "when transaction status is not approved or declined" do
      let(:status) { :error }

      it "does not send webhook" do
        expect(WebMock).not_to have_requested(:post, webhook_url)
        described_class.perform_now(authorize)
      end
    end

    context "when transaction status is approved" do
      let(:status) { :approved }

      it "sends webhook with approved status" do
        described_class.perform_now(authorize)
        expect(WebMock).to have_requested(:post, webhook_url)
          .with(body: {"amount" => authorize.amount, "status" => "approved", "unique_id" => authorize.unique_id})
      end
    end

    context "when transaction status is declined" do
      let(:status) { :declined }

      it "sends webhook with declined status" do
        described_class.perform_now(authorize)
        expect(WebMock).to have_requested(:post, webhook_url)
          .with(body: {"amount" => authorize.amount, "status" => "declined", "unique_id" => authorize.unique_id})
      end
    end

    context "when request successful" do
      before { stub_request(:post, webhook_url).to_return(status: 201) }

      it "updates notification_status to successful and sets last_notification_at" do
        expect {
          described_class.perform_now(authorize)
        }.to change(authorize, :notification).from("pending").to("successful")
        expect(authorize.last_notification_at).to eq(DateTime.current)
      end
    end

    context "when request failed" do
      before { stub_request(:post, webhook_url).to_return(status: 500) }

      it "reschedules the request in 5 minutes and sets last_notification_at" do
        described_class.perform_now(authorize)
        expect(described_class).to have_been_enqueued
        expect(authorize.notification).to eq("pending")
        expect(authorize.last_notification_at).to eq(DateTime.current)
      end

      context "when failed 5 retries" do
        before do
          ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
          ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
          stub_request(:post, webhook_url).to_return(status: 500)
        end

        it "updates status to successful and sets last_notification_at" do
          described_class.perform_now(authorize)
          authorize.reload
          expect(described_class).not_to have_been_enqueued
          expect(authorize.notification).to eq("failed")
          expect(authorize.last_notification_at).to eq(DateTime.current)
          expect(authorize.notification_attempts).to eq(5)
        end
      end
    end
  end
end
