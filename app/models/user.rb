class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # Returns a session token to prevent session hijacking.
  # We reuse remember_digest for convenience.
  def session_token
    remember_digest || remember # Is remember_digest field not
                                # emtpy? Great! Then let's return
                                # it. Is it empty? Ok, lets create
                                # a new token, assign it to the
                                # class attribute (NOT a db field!)
                                # 'remember_token'. Next line NOW 
                                # we can update 'remember_digest'
                                # (A db field) with the 'digested'
                                # version of remember_token.
                                # Short version: remember_digest
                                # not empty? Return it!. Empty?
                                # Fill it creating the content,
                                # and return it!
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return unless remember_digest
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  class << self
    # Returns the hash digest of the given string.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  
    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
end
