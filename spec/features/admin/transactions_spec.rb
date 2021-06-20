require "features_helper"

describe "Transactions", :js, type: :feature do
  before do
    sign_in admin.email, "password"
  end

  let(:admin) { create(:admin, password: "password") }

  describe "Index page" do
    before do
      3.times do
        create(:authorize,
          status: "pending",
          notification_url: "https://google.com/psystem_webhook",
          customer_email: "customer@example.com",
          customer_phone: "+79999999999")
      end

      visit admin_transactions_path
    end

    let(:transaction) { Transaction.last }

    it "shows the list of transactions sorted desc" do
      expect(page).to have_css("table.table tbody tr", count: 3)

      first_row = page.first("table.table tbody tr")
      expect(first_row.find("td.id")).to have_text(transaction.id)
      expect(first_row.find("td.type")).to have_text(transaction.type_name)
      expect(first_row.find("td.status")).to have_text(transaction.status)
      expect(first_row.find("td.amount")).to have_text(transaction.amount)
      expect(first_row.find("td.extra")).to have_text(<<-TEXT.squish)
        UUID: #{transaction.uuid}
        Unique ID: #{transaction.unique_id}
        Notification URL: #{transaction.notification_url}
        Customer Email: #{transaction.customer_email}
        Customer Phone: #{transaction.customer_phone}
      TEXT
    end
  end
end
