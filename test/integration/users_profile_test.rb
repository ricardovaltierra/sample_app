require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name) # To note here how we gained access to the 'full title' helper method, thanks to including the ApplicationHelper on the first line above.
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar' # We're going to find an img tag with 'gravatar' class nested in the h1.
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do  |micropost|
      assert_match micropost.content, response.body
    end
  end
end
