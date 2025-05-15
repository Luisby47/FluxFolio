import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static values = {
    preventReload: Boolean
  }

  connect() {
    // Prevent scrolling on the background when modal is open
    document.body.style.overflow = "hidden"

    // Store the current URL to detect history changes
    this.originalUrl = window.location.href
  }

  disconnect() {
    // Re-enable scrolling when modal is closed
    document.body.style.overflow = "auto"
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.closeModal(event)
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.closeModal(event)
    }
  }

  close(event) {
    this.closeModal(event)
  }

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
      window.history.back()
    }
  }
}
