class Admin::MerchantsController < Admin::ApplicationController
  before_action :set_merchant, only: [:show, :edit, :update, :destroy]

  def index
    @merchants = Merchant.order(:created_at).all
  end

  def show
  end

  def new
    @merchant = Merchant.new
  end

  def edit
  end

  def create
    @merchant = Merchant.new(merchant_params)

    if @merchant.save
      redirect_to admin_merchant_path(@merchant)
    else
      render :new
    end
  end

  def update
    if @merchant.update(merchant_params)
      redirect_to admin_merchant_path(@merchant)
    else
      render :edit
    end
  end

  def destroy
    if !@merchant.destroy
      flash[:alert] = @merchant.errors.full_messages.to_sentence
      flash[:alert] = @merchant.account.errors.full_messages.to_sentence
    end

    redirect_to admin_merchants_path
  end

  private

  def set_merchant
    @merchant = Merchant.find(params[:id])
  end

  def merchant_params
    params.require(:merchant).permit(:email, :password, :status, :name, :description)
  end
end
