import { Controller } from "@hotwired/stimulus"

/**
 * Modal Controller
 * 
 * This Stimulus controller manages modal dialog behavior in the application.
 * It handles opening and closing of modals, background scrolling prevention,
 * keyboard navigation, click events, and browser history management.
 */
export default class extends Controller {
  // Values that can be passed from HTML
  static values = {
    preventReload: Boolean // When true, closing modal doesn't trigger browser navigation
  }

  /**
   * Initialize the modal when controller connects to the DOM
   * Sets up scrolling prevention and stores original URL for history management
   */
  connect() {
    // Prevent scrolling on the background when modal is open
    document.body.style.overflow = "hidden"

    // Store the current URL to detect history changes
    this.originalUrl = window.location.href
  }

  /**
   * Clean up when modal is disconnected from the DOM
   * Restores scrolling behavior
   */
  disconnect() {
    // Re-enable scrolling when modal is closed
    document.body.style.overflow = "auto"
  }

  /**
   * Close the modal when clicking on the background (outside the modal content)
   * Only closes if the click target is the modal background itself
   * @param {Event} event - Click event
   */
  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.closeModal(event)
    }
  }

  /**
   * Handle keyboard events for accessibility
   * Closes the modal when Escape key is pressed
   * @param {KeyboardEvent} event - Keyboard event
   */
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.closeModal(event)
    }
  }

  /**
   * Close button click handler
   * @param {Event} event - Click event
   */
  close(event) {
    this.closeModal(event)
  }

  /**
   * Core modal closing logic
   * Either navigates back in history or removes modal content based on configuration
   * @param {Event} event - The triggering event
   */
  closeModal(event) {
    if (event) {
      event.preventDefault()
    }
    
    // If preventReload value is true or we're in a frame, don't use history.back()
    if (this.hasPreventReloadValue && this.preventReloadValue) {
      // Just hide the modal without navigating
      const frame = document.getElementById('modal')
      if (frame) {
        frame.innerHTML = ''
      }
    } else {
      // Use history.back() which won't reload the page
      // This works because modals are shown in response to navigation events
      window.history.back()
    }
  }
}
