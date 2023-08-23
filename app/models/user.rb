class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  before_create :create_activation_digest
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
  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # forget a user
  def forget
    update_column :remember_digest, nil
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Activates an account.
  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  private
  def downcase_email
    email.downcase!
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
