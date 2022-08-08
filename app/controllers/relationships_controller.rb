class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    # We get the params[:followed_id] from the
    # 'follow' button clicked on browser, that
    # is actually a form with just a submit 
    # 'follow' button
    @user = User.find (params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  end

  def destroy
    # Same, get the params[:id] from the 
    # form that looks like an 'unfollow'
    # button to check Relationships table
    # and take the followed_id, and from
    # there the user
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end
