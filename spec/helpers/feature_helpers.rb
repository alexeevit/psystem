module FeatureHelpers
  def sign_in(email, password)
    visit "/admin/sign_in"

    fill_in :email, with: email
    fill_in :password, with: password
    click_button "Submit"
  end
end
