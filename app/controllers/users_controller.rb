class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
  end 


  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # Handle a successful save.
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

    # identation suggested by M. Hartl to identify private methods
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
