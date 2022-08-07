require "test_helper"

# Here, the class name is not ending with the word 'Test'
# since minitest automatically runs all classes ending
# with this word, and we want the below one just for
# inheritance
class PasswordResets < ActionDispatch::IntegrationTest

  def setup
    # Clear registered sent mails so this are not 
    # detected by the tests
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
end

class ForgotPasswordFormTest < PasswordResets

  test "password reset path" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  test "reset path with invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

class PasswordResetForm < PasswordResets

  def setup
    # super, to send the parameter to
    # setup mehtod set on parent
    super
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm

  test "reset with valid email" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "reset with wrong email" do
    get edit_password_reset_path(@reset_user.reset_token, email: '')
    assert_redirected_to root_url
  end

  test "reset with inactive user" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "reset with right email but wrong token" do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "reset with right email and right token" do
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm

  test "update with invalid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" }}
    assert_select 'div#error_explanation'
  end

  test "update with empty password" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  test "update with valid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    @reset_user.reload
    assert_nil @reset_user.reset_digest
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
  end
end

class ExpiredToken < PasswordResets
  def setup
    # super again, to pass the parameters up to the
    # parent
    super
    # Create a password-reset token.
    post password_resets_path,
         # Do you remember the 'password_reset[email]'
         # input field from above?
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    # Expire the token by hand.
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # Attempt to update the user's password.
    # here we send the reset token since the path has it
    # embedded in the middle
    patch password_reset_path(@reset_user.reset_token),
    # And now the params hash for the patch request,
    # the hash that is supposed to have the data
    # (coming from the form) that will update the db
          params: { email: @reset_user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    
  end
end

class ExpiredTokenTest < ExpiredToken

  test "should redirect to the password reset page" do
    assert_redirected_to new_password_reset_url
  end

  test "should include the word 'expired' on the password reset page" do
    follow_redirect!
    # Here, 'response.body' is used to find a match of the word
    # 'expired' over all of the response HTML 
    assert_match /expired/i, response.body
  end
end
