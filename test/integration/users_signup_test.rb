require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information" do
    assert_difference 'User.count', 1 do
      # Generates a post request to the server, to users_path, so redirecting
      # to the users controller and the create action (beacuse POST), taking
      # the data for the user creation from the incoming params hash
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!              # The test will catch an eye where the site goes after
                                  # submission
    assert_template 'users/show'  # As usual learning Rails, after submitting any form
                                  # the next page has the view with the detailed info
                                  # about what was just saved (i.e. Profile page)
    assert_not flash.empty?
  end
end
