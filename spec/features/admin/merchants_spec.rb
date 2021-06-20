require "features_helper"

describe "Merchants management", :js, type: :feature do
  before do
    sign_in admin.email, "password"

    3.times do
      create(:merchant)
    end
  end

  let(:admin) { create(:admin, password: "password") }
  let(:first_merchant) { Merchant.first }

  describe "Index page" do
    before { visit admin_merchants_path }

    it "shows the list of merchants" do
      expect(page).to have_css("table.table tbody tr", count: 3)

      first_merchant_row = page.first("table.table tbody tr")
      expect(first_merchant_row.find("td.id")).to have_text(first_merchant.id)
      expect(first_merchant_row.find("td.status")).to have_text(first_merchant.status.capitalize)
      expect(first_merchant_row.find("td.email")).to have_text(first_merchant.email)
      expect(first_merchant_row.find("td.name")).to have_text(first_merchant.name)

      expect(first_merchant_row.find("td.actions")).to have_link("Edit", href: edit_admin_merchant_path(first_merchant))
      expect(first_merchant_row.find("td.actions")).to have_link("Delete", href: admin_merchant_path(first_merchant))
    end
  end

  describe "Show page" do
    before { visit admin_merchant_path(first_merchant) }

    it "shows the list of merchants" do
      table = page.find("table.table")

      expect(table.find("td.id")).to have_text(first_merchant.id)
      expect(table.find("td.status")).to have_text(first_merchant.status.capitalize)
      expect(table.find("td.email")).to have_text(first_merchant.email)
      expect(table.find("td.name")).to have_text(first_merchant.name)
      expect(table.find("td.description")).to have_text(first_merchant.description)
    end
  end

  describe "New page" do
    before { visit new_admin_merchant_path }

    it "creates a merchant and redirects to index page" do
      fill_in "merchant[email]", with: "custom-merchant@example.com"
      fill_in "merchant[password]", with: "password"
      fill_in "merchant[name]", with: "John"
      fill_in "merchant[description]", with: "Good boy"

      expect {
        click_button "Submit"
      }.to change(Merchant, :count).from(3).to(4)
      expect(current_path).to eq(admin_merchant_path(Merchant.last))
    end
  end

  describe "Edit page" do
    before { visit edit_admin_merchant_path(first_merchant) }

    it "updates a merchant and redirects to index page" do
      fill_in "merchant[email]", with: "custom-merchant@example.com"
      select "Inactive", from: "merchant[status]"
      fill_in "merchant[password]", with: "password"
      fill_in "merchant[name]", with: "John"
      fill_in "merchant[description]", with: "Good boy"

      expect {
        click_button "Submit"
      }.to change { current_path }.from(edit_admin_merchant_path(first_merchant)).to(admin_merchant_path(first_merchant))

      first_merchant.reload
      expect(Merchant.count).to eq(3)
      expect(first_merchant.email).to eq("custom-merchant@example.com")
      expect(first_merchant.status).to eq("inactive")
      expect(first_merchant.name).to eq("John")
      expect(first_merchant.description).to eq("Good boy")
    end
  end

  describe "Deletion" do
    it "deletes a merchant and redirects to index page" do
      visit admin_merchants_path
      actions = page.first("table.table tbody tr td.actions")

      expect {
        accept_prompt { actions.click_link "Delete" }
      }.to change(Merchant, :count).from(3).to(2)
      expect(current_path).to eq(admin_merchants_path)
    end
  end
end
