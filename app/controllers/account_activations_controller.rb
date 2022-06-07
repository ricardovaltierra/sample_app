class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    # Below, params[:id] should contain the activation token to be used
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.update_attribute(:activated, true)
      user.update_attribute(:activated_at, Time.zone.now)
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else # In the case the token can not be authenticated
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
