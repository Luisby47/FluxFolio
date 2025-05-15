# SignupsController manages user registration
# This controller handles new user account creation
class SignupsController < ApplicationController
  # Allow unauthenticated users to access registration form and signup action
  allow_unauthenticated_access only: %i[ new create ]

  # GET /signup/new
  # Display the user registration form
  def new
    @user = User.new
  end

  # POST /signup
  # Process user registration and create a new user account
  def create
    @user = User.new(user_params)

    if @user.save
      # Automatically log in the user after successful registration
      start_new_session_for @user
      # Redirect to main application page with welcome message
      redirect_to after_authentication_url, notice: "Welcome to Fluxfolio!"
    else
      # Registration failed, show form with validation errors
      render :new, status: :unprocessable_entity
    end
  end

  private

    # Define permitted parameters for user registration
    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
end
