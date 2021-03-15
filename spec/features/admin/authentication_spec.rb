require "features_helper"

describe "Authentication", :js, type: :feature do
  let!(:admin) { create(:admin, password: password) }
  let!(:merchant) { create(:merchant, password: password) }
  let(:password) { "password" }

  context "when not authenticated" do
    it "redirects to sign_in" do
      visit "/admin"
      expect(current_path).to eq("/admin/sign_in")
    end

    it "does not authenticate merchants" do
      sign_in(merchant.email, password)
      expect(current_path).to eq("/admin/sign_in")
    end

    it "authenticates admin and redirects to the welcome page" do
      sign_in(admin.email, password)
      expect(current_path).to eq("/admin")
    end

    it "shows error if the email or password are not valid" do
      sign_in("random@example.com", "wrong-password")

      expect(current_path).to eq("/admin/sign_in")
      expect(page).to have_css(".alert.alert-danger")
      expect(page.find(".alert.alert-danger")).to have_text("Invalid email or password")
    end
  end

  context "when authenticated" do
    before { sign_in(admin.email, password) }

    it "does not redirect" do
      visit "/admin"
      expect(current_path).to eq("/admin")
    end

    it "logs out" do
      page.find("nav").click_link("Logout")
      expect(current_path).to eq("/admin/sign_in")
    end
  end

  def sign_in(email, password)
    visit "/admin/sign_in"

    fill_in :email, with: email
    fill_in :password, with: password
    click_button "Submit"
  end
end
