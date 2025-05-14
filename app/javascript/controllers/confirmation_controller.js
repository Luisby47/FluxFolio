import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirmation"
export default class extends Controller {
  confirm(event) {
    const message = event.currentTarget.dataset.confirm || "Are you sure?"
    if (!window.confirm(message)) {
      event.preventDefault()
    }
  }
} 