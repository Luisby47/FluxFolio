# SessionsController manages user authentication sessions
# This controller handles user login, logout, and session management
class SessionsController < ApplicationController
  # Allow unauthenticated users to access login form and login action
  allow_unauthenticated_access only: %i[ new create ]
  # Apply rate limiting to prevent brute force attacks
  # Limits to 10 attempts within 3 minutes
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  # GET /session/new
  # Display the login form
  # Also handles the case where an authenticated user revisits the login page
  def new
    if authenticated?
      # If already logged in, terminate the current session
      terminate_session
    end
  end

  # POST /session
  # Process login attempt and create a new session
  def create
    # Attempt to authenticate user with provided credentials
    if user = User.authenticate_by(params.permit(:email_address, :password))
      # Check if account is disabled
      redirect_to new_session_path, alert: "Your account has been disabled." if user.disabled?
      # Create new session for the authenticated user
      start_new_session_for user
      # Redirect to main application page after successful login
      redirect_to after_authentication_url
    else
      # Authentication failed, show error message
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  # DELETE /session
  # Log out the current user by terminating their session
  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
