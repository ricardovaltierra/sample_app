require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    # assert that a div with 'pagination' class is
    # present on the page
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1).each do |user|
      # Here, it is going to assert that for every user of the
      # first page as noted above in the page param, there is 
      # a link to the user path (user profile) and that the link
      # has as text the user name in turn.
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
