class User < ApplicationRecord
  before_save :downcase_email
  validates :name, presence: true,
            length: {maximum: Settings.username_max_length}
  validates :email, presence: true,
            length: {maximum: Settings.email_max_length},
            format: {with: Settings.valid_email_regex},
            uniqueness: true
  validates :password, presence: true,
            length: {minimum: Settings.password_min_length}
  has_secure_password

  def downcase_email
    email.downcase!
  end
end
