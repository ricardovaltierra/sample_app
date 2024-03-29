require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "layout links" do
    # links without logging in
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path

    get signup_path
    assert_select "title", full_title("Sign up")

    log_in_as(@user)
    # links logging in
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
    
    get about_path
    assert_select "title", full_title("About")

    get contact_path
    assert_select "title", full_title("Contact")
    
    get help_path
    assert_select "title", full_title("Help")

    get users_path
    assert_select "title", full_title("All users")

    get user_path(@user)
    assert_select "title", full_title(@user.name)

    get edit_user_path(@user)
    assert_select "title", full_title("Edit user")
  end
end
