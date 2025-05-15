# PasswordsController manages password reset functionality
# This controller handles the password reset flow, including requesting a reset,
# sending reset emails, and processing new password submissions
class PasswordsController < ApplicationController
  # Allow unauthenticated users to access all password reset actions
  allow_unauthenticated_access
  # Verify reset token before allowing password change
  before_action :set_user_by_token, only: %i[ edit update ]

  # GET /passwords/new
  # Display form to request a password reset
  def new
  end

  # POST /passwords
  # Process password reset request and send reset email
  def create
    if user = User.find_by(email_address: params[:email_address])
      # Send password reset email with secure token
      PasswordsMailer.reset(user).deliver_later
    end

    # Always show the same message whether user exists or not (security best practice)
    # This prevents user enumeration attacks
    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  # GET /passwords/:token/edit
  # Display form to enter new password after clicking reset link in email
  def edit
  end

  # PATCH/PUT /passwords/:token
  # Process new password submission and update user account
  def update
    if @user.update(params.permit(:password, :password_confirmation))
      # Password reset successful, redirect to login
      redirect_to new_session_path, notice: "Password has been reset."
    else
      # Password validation failed, show errors
      redirect_to edit_password_path(params[:token]), alert: "#{@user.errors.full_messages.join(", ")}"
    end
  end

  private
    # Find user by secure reset token from email link
    # Redirects to reset request page if token is invalid or expired
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
