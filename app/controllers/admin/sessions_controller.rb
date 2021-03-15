class Admin::SessionsController < Admin::ApplicationController
  layout "empty"
  skip_before_action :check_signed_in, except: [:destroy]

  def new
    redirect_to admin_root_path if signed_in?
  end

  def create
    admin = Admin.find_by(email: params[:email])

    if admin&.authenticate(params[:password])
      session[:user_id] = admin.id
      redirect_to admin_root_path
    else
      flash[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    destroy_session
    redirect_to admin_sign_in_path
  end
end
