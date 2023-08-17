class User < ApplicationRecord
  before_save :downcase_email
  VALID_EMAIL_REGEX = Settings.VALID_EMAIL_REGEX
  validates :name, presence: true, length: {maximum: Settings.USERNAME_MAX_LENGTH}
  validates :email, presence: true, length: {maximum: Settings.EMAIL_MAX_LENGTH},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: true
  validates :password, presence: true, length: {maximum: Settings.PASSWORD_MIN_LENGTH}
  has_secure_password

  def downcase_email
    self.email.downcase!
  end
end
