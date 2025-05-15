# User model represents application users with authentication capabilities
# It handles user accounts, password management, and relationships to other models
class User < ApplicationRecord
  # Use built-in Rails features for password management
  has_secure_password
  
  # Relationships - a user can have multiple portfolios
  has_many :portfolios, dependent: :destroy
  # NoteDrafts are user-specific unsaved notes
  has_many :note_drafts, dependent: :destroy
  # Sessions track user login instances
  has_many :sessions, dependent: :destroy
  
  # Validations for email format and uniqueness
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, 
                          presence: true,
                          uniqueness: { case_sensitive: false }
  
  # Password validation to ensure minimum security requirements                        
  validates :password, allow_nil: true, length: { minimum: 8 },
                      format: { with: /\A.*[a-z].*\z/i, message: "must contain at least one letter" },
                      format: { with: /\A.*[0-9].*\z/, message: "must contain at least one number" },
                      format: { with: /\A.*[^A-Za-z0-9].*\z/, message: "must contain at least one special character" }
  
  # Normalize email address before validation to ensure consistent format
  before_validation :normalize_email_address
  
  # Class method to authenticate with email and password
  # Returns the user if authentication succeeds, nil otherwise
  def self.authenticate_by(email_address:, password:)
    # Find user by downcased email (case-insensitive lookup)
    user = find_by(email_address: email_address.downcase)
    
    # Use authenticate method from has_secure_password to check password
    # Returns user if password matches, false otherwise
    user&.authenticate(password)
  end
  
  private
  
    # Normalize email to lowercase for consistent lookup
    def normalize_email_address
      self.email_address = email_address.to_s.downcase
    end
end
