class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    # First, find the user we're going to follow
    user = User.find(params[:followed_id])
    # The current logged in add a follower with
    # follow model method
    current_user.follow(user)
    redirect_to user
  end

  def destroy
    # We take the followed one, form the Relationship
    # corresponding record with the params[:id]
    user = Relationship.find(params[:id]).followed
    # Using 'unfollow' User model method, removes
    # the desired record
    current_user.unfollow(user)
    # :see_other, 'cause we deleted a record
    redirect_to user, status: :see_other
  end
end
