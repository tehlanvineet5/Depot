class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :email_address,
    presence: true,
    uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  has_secure_password
  has_many :sessions, dependent: :destroy
  after_create :send_welcome_email
  before_update :ensure_admin_cannot_be_updated
  before_destroy :prevent_admin_deletion

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  after_destroy :ensure_an_admin_remains

  class Error < StandardError
  end

  private
    def ensure_an_admin_remains
      if User.count.zero?
        raise Error.new "Can't delete last user"
      end
    end
    def send_welcome_email
      UserMailer.with(user: self).welcome_email.deliver_later
    end
    def prevent_admin_deletion
      if email_address_in_database == "admin@depot.com"
        errors.add(:base, "Admin user cannot be destroyed")
        throw :abort
      end
    end
    def ensure_admin_cannot_be_updated
      if email_address_in_database == "admin@depot.com"
        errors.add(:base, "Admin user cannot be updated")
        throw :abort
      end
    end
end
