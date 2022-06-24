require "test_helper"

class Following < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user) # As usual
  end
end

class FollowPagesTest < Following

  test "following page" do
    get following_user_path(@user)
    assert_response :unprocessable_entity
    assert_not @user.following.empty? # Because of the set relationships fixtures
    # Just check below that the count is on the HTML body
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      # A link (a gravatar one) to the user profile
      # for each one of the followed users
      assert_select 'a[href=?]', user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_response :unprocessable_entity
    assert_not @user.followers.empty? # Again because fixtures
    assert_match @user.followers.count.to_s, response.body # Again just checking the number
    @user.followers.each do |user|
      # Again, a link for each user following @user
      assert_select 'a[href=?]', user_path(user)
    end
  end
end
