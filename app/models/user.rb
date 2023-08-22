class User < ApplicationRecord
  attr_accessor :remember_token

  before_save :downcase_email
  validates :name, presence: true,
            length: {maximum: Settings.username_max_length}
  validates :email, presence: true,
            length: {maximum: Settings.email_max_length},
            format: {with: Settings.valid_email_regex},
            uniqueness: true
  validates :password, presence: true, allow_nil: true,
            length: {minimum: Settings.password_min_length}
  has_secure_password

  def downcase_email
    email.downcase!
  end

  # Returns the hash digest of the given string.
  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
    remember_digest
  end

  # Returns a session token to prevent session hijacking.
  def session_token
    remember_digest || remember
  end

  # Returns true if the given token matches the digest.
  def authenticated? remember_token
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # forget a user
  def forget
    update_column :remember_digest, nil
  end
end
