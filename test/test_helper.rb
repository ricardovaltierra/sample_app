ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!
class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper
  # Add more helper methods to be used by all tests here...

  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Log in as a particular user.
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
  # Log in as a particular user. (BUT ONLY OVER THE INTEGRATION TESTS,
  # the one above with same name is for controller tests)
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params:  { session: { email: user.email,
                                           password: password,
                                           remember_me: remember_me } }
  end

  def image_gravatar_tag(user, size: 80)
    gravatar_id  = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    "<img alt=\"#{user.name}\" class=\"gravatar\" src=\"#{gravatar_url}\">"
  end
end