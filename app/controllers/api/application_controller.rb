class Api::ApplicationController < ApplicationController
  before_action :authenticate_and_set_merchant
end
