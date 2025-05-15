# ApplicationController is the base controller for the application
# It includes common functionality used across all controllers
class ApplicationController < ActionController::Base
  # Include authentication functionality from a concern
  include Authentication
  # Include application-wide helper methods
  include Application
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # This prevents old browsers from accessing the site and ensures a consistent experience
  allow_browser versions: :modern

  # Set up current request details before processing any request
  before_action :set_current_request_details

  private

    # Store request details in the Current object for access throughout the request lifecycle
    # This allows access to request information without passing it through parameters
    def set_current_request_details
      Current.request_id = request.uuid
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end
end
