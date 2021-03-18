require "rails_helper"

describe "Authentication", type: :api do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  let!(:merchant) { create(:merchant, email: email, password: password, account: create(:account)) }
  let(:email) { "merchant@example.com" }
  let(:password) { "password" }

  describe "POST /api/merchants/sign_in" do
    context "when valid credentials" do
      it "is successful and returns Access-Code" do
        post_with_json "/api/merchants/sign_in", {email: email, password: password}
        expect(last_response).to be_successful
        expect(last_response.headers).to have_key("Access-Token")
      end
    end

    context "when invalid credentials" do
      it "returns 422" do
        post_with_json "/api/merchants/sign_in", {email: email, password: "invalid"}
        expect(last_response.status).to eq(422)
      end
    end
  end

  context "when authenticated" do
    let(:token) { jwt_and_refresh_token(merchant, "merchant").first }

    it "returns 200" do
      header "Authorization", "Bearer #{token}"

      get "/api/transactions.json"
      expect(last_response).to be_successful
    end
  end

  context "when not authenticated" do
    it "returns 401" do
      get "/api/transactions.json"
      expect(last_response.status).to eq(401)
    end
  end

  def post_with_json(uri, data)
    json = JSON.generate(data)
    headers = {"CONTENT_TYPE" => "application/json"}
    post(uri, json, headers)
  end
end
