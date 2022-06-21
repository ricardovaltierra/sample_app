require "test_helper"

class MicropostInterface < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostInterfaceTest < MicropostInterface

  test "should paginate microposts" do
    get root_path
    # Assert there should be at least one div with 'pagination' class
    assert_select 'div.pagination'
  end

  test "should show errors but not create micropost on invalid submission" do
    # There should not be any difference in the count of microposts
    # when the code inside below's block run
    assert_no_difference 'Micropost.count' do
      # There should not be difference in the number of
      # microposts, since empty content not allowed
      post microposts_path, params: { micropost: { content: "" } }
    end
    # Assert that, after there was no micropost creation
    # it appears a div with an 'error_explanation' id
    # and a link with the href content set
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2' # Correct pagination link
  end

  test "should create a micropost on valid submission" do
    content = "This micropost really ties the room together"
    # Now there should be a difference of one when
    # checking the result of 'Micropost.count'
    assert_difference 'Micropost.count', 1 do
      # Now we have a contetnt for the micropost
      # As is valid, should be created
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    # Above we visit the redirected page for 
    # 'root_url', and on the response body
    # look inside for the content text
    # appearing at least once
    assert_match content, response.body
  end

  test "should have micropost delete links on own profile page" do
    get users_path(@user)
    # There should be a link with 'delete' text
    assert_select 'a', text: 'delete'
  end

  test "should be able to delete own micropost" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "should not have delete links on other user's profile page" do
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
end
