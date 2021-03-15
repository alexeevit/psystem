class Admin::ApplicationController < ApplicationController
  before_action :check_signed_in
  before_action :update_session

  helper_method :signed_in?, :current_user

  private

  def current_admin
    if session[:user_id]
      @admin ||= User.find(session[:user_id])
    end
  end

  def signed_in?
    !!current_admin
  end

  def check_signed_in
    if session[:expired_at] && session[:expired_at] < Time.now.utc
      destroy_session
    end

    redirect_to admin_sign_in_path unless signed_in?
  end

  def update_session
    session[:expired_at] = Time.now.utc + 1.year
  end

  def destroy_session
    session[:user_id] = nil
    session[:expired_at] = nil
  end
end
