require "rails_helper"

describe "Api::Transactions", type: :api do
  let!(:merchant) { create(:merchant, status: merchant_status, account: create(:account)) }
  let(:merchant_status) { :active }
  let(:token) { jwt_and_refresh_token(merchant, "merchant").first }

  before do
    Timecop.freeze(DateTime.new(2021, 1, 1, 9, 30, 0))
    header "Authorization", "Bearer #{token}"
  end

  after { Timecop.return }

  describe "GET /api/transactions" do
    let!(:transaction) { create(:authorize, account: merchant.account, amount: 100) }

    context "when json request" do
      it "returns all transactions" do
        get "/api/transactions.json"
        expect(json_response).to eq([
          {
            "amount" => 100,
            "created_at" => 1609493400,
            "customer_email" => nil,
            "customer_phone" => nil,
            "notification_url" => nil,
            "status" => "approved",
            "type" => "authorize",
            "unique_id" => transaction.unique_id
          }
        ])
      end
    end

    context "when xml request" do
      it "returns all transactions" do
        get "/api/transactions.xml"
        expect(xml_response).to eq([
          {
            "amount" => 100,
            "created_at" => 1609493400,
            "customer_email" => nil,
            "customer_phone" => nil,
            "notification_url" => nil,
            "status" => "approved",
            "type" => "authorize",
            "unique_id" => transaction.unique_id
          }
        ])
      end
    end
  end

  describe "POST /api/transactions" do
    context "when merchant is not active" do
      let(:merchant_status) { :inactive }

      it "returns 403" do
        post_with_json "/api/transactions.json", {}
        expect(last_response.status).to eq(403)
        expect(json_response).to eq("errors" => ["inactive merchant"])
      end
    end

    context "when merchant is active" do
      context "when authorized transaction" do
        let(:params) do
          {
            type: :authorize,
            amount: 100,
            notification_url: "https://google.com/psystem_webhook",
            customer_email: "johnbowie@gmail.com"
          }
        end

        it "creates transaction and returns it if all params are valid" do
          post_with_json "/api/transactions.json", params

          transaction = Transactions::Authorize.last
          expect(last_response).to be_successful
          expect(json_response).to include({
            "unique_id" => transaction.unique_id,
            "status" => "pending",
            "amount" => 100,
            "notification_url" => "https://google.com/psystem_webhook",
            "customer_email" => "johnbowie@gmail.com",
            "customer_phone" => nil
          })
        end

        it "fails if blank amount" do
          params.delete(:amount)

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount is blank"])
        end

        it "fails if non-integer amount" do
          params[:amount] = "string"

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount has non-integer value"])
        end

        it "fails if non-positive amount" do
          params[:amount] = -10

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount is not positive"])
        end

        it "fails if blank notification_url" do
          params.delete(:notification_url)

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["notification_url is blank"])
        end

        it "fails if invalid notification_url" do
          params[:notification_url] = "not url"

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["notification_url is invalid url"])
        end

        it "fails if empty customer_email" do
          params.delete(:customer_email)

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["customer_email is blank"])
        end

        it "fails if invalid customer_email" do
          params[:customer_email] = "not email"

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["customer_email is invalid email"])
        end
      end

      context "when capture transaction" do
        let(:authorize) { create(:authorize, status: authorize_status, account: merchant.account, amount: 100) }
        let(:authorize_status) { :approved }
        let(:params) do
          {
            type: :capture,
            unique_id: authorize.unique_id,
            amount: 100
          }
        end

        it "creates transaction and returns it if all params are valid" do
          post_with_json "/api/transactions.json", params

          transaction = Transactions::Capture.last
          expect(last_response).to be_successful
          expect(json_response).to include({
            "unique_id" => transaction.unique_id,
            "status" => "approved",
            "amount" => 100
          })
        end

        it "fails if blank amount" do
          params.delete(:amount)

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount is blank"])
        end

        it "fails if non-integer amount" do
          params[:amount] = "string"

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount has non-integer value"])
        end

        it "fails if non-positive amount" do
          params[:amount] = -10

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount is not positive"])
        end

        it "fails if invalid unique_id" do
          params[:unique_id] = "invalid"

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["invalid unique_id"])
        end

        it "fails if captured amount is greater than authorized" do
          params[:amount] = 101

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount exceeds the authorized amount"])
        end

        context "when authorize is not approved or captured" do
          let(:authorize_status) { :error }

          it "fails" do
            post_with_json "/api/transactions.json", params
            expect(last_response.status).to eq(422)
            expect(json_response).to eq("errors" => ["authorize_status is \"#{authorize_status}\""])
          end
        end
      end

      context "when refund transaction" do
        before do
          create(:capture, amount: 100, uuid: authorize.uuid, account: merchant.account)
        end

        let(:authorize) { create(:authorize, status: :captured, account: merchant.account, amount: 100) }
        let(:params) do
          {
            type: :refund,
            unique_id: authorize.unique_id,
            amount: 100
          }
        end

        it "creates transaction and returns it if all params are valid" do
          post_with_json "/api/transactions.json", params

          transaction = Transactions::Refund.last
          expect(last_response).to be_successful
          expect(json_response).to include({
            "unique_id" => transaction.unique_id,
            "status" => "approved",
            "amount" => 100
          })
        end

        it "fails if blank amount" do
          params.delete(:amount)

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount is blank"])
        end

        it "fails if non-integer amount" do
          params[:amount] = "string"

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount has non-integer value"])
        end

        it "fails if non-positive amount" do
          params[:amount] = -10

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount is not positive"])
        end

        it "fails if invalid unique_id" do
          params[:unique_id] = "invalid"

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["invalid unique_id"])
        end

        it "fails if refunded amount is greater than captured" do
          params[:amount] = 101

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["amount exceeds the captured amount"])
        end
      end

      context "when void transaction" do
        let(:authorize) { create(:authorize, status: authorize_status, account: merchant.account, amount: 100) }
        let(:authorize_status) { :approved }
        let(:params) do
          {
            type: :void,
            unique_id: authorize.unique_id
          }
        end

        it "creates transaction and returns it if all params are valid" do
          post_with_json "/api/transactions.json", params

          transaction = Transactions::Void.last
          expect(last_response).to be_successful
          expect(json_response).to include({
            "unique_id" => transaction.unique_id,
            "status" => "approved"
          })
        end

        it "fails if invalid unique_id" do
          params[:unique_id] = "invalid"

          post_with_json "/api/transactions.json", params
          expect(last_response.status).to eq(422)
          expect(json_response).to eq("errors" => ["invalid unique_id"])
        end

        context "when authorize is not approved" do
          let(:authorize_status) { :error }

          it "fails" do
            post_with_json "/api/transactions.json", params
            expect(last_response.status).to eq(422)
            expect(json_response).to eq("errors" => ["authorize_status is \"#{authorize_status}\""])
          end
        end
      end
    end

    context "when xml format" do
      let(:merchant_status) { :active }
      let(:params) do
        {
          type: :authorize,
          amount: 100,
          notification_url: "https://google.com/psystem_webhook",
          customer_email: "johnbowie@gmail.com"
        }
      end

      it "creates transaction and returns it if all params are valid" do
        post_with_xml "/api/transactions.xml", params

        transaction = Transactions::Authorize.last
        expect(last_response).to be_successful
        expect(xml_response).to include({
          "unique_id" => transaction.unique_id,
          "status" => "pending",
          "amount" => 100,
          "notification_url" => "https://google.com/psystem_webhook",
          "customer_email" => "johnbowie@gmail.com",
          "customer_phone" => nil
        })
      end
    end
  end
end
