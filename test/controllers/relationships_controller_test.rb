require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  test "create should require logged-in user" do
    # 'Follow' button actually creates a record
    # on the Relationships db table
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end

  test "destroy should require logged-in user" do
    # 'Unfollow' button actually destroys a record
    # from the Relationships table
    assert_no_difference 'Relationship.count' do
      # We send the fixture relationship :one
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end
