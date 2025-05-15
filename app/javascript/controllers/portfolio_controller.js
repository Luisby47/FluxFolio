import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

/**
 * Portfolio Controller
 * 
 * This Stimulus controller manages portfolio selection behavior.
 * It handles navigation between portfolios using a select dropdown,
 * redirecting the user to the selected portfolio page without a full page reload.
 */
export default class extends Controller {
  // Elements that can be targeted in the DOM
  static targets = ["select"] // The select dropdown for portfolio navigation

  /**
   * Set up event listeners when controller connects to the DOM
   */
  connect() {
    if (this.hasSelectTarget) {
      // Add change event listener to the portfolio select dropdown
      this.selectTarget.addEventListener("change", this.handleChange.bind(this))
    }
  }

  /**
   * Handle portfolio selection changes
   * Navigates to the selected portfolio using Turbo for a smooth transition
   * 
   * @param {Event} event - Change event from the select dropdown
   */
  handleChange(event) {
    const portfolioId = event.target.value
    if (portfolioId) {
      // Navigate to the selected portfolio's page
      Turbo.visit(`/portfolios/${portfolioId}`, { action: "advance" })
    } else {
      // Navigate to the portfolios index if no portfolio is selected
      Turbo.visit("/portfolios", { action: "advance" })
    }
  }
}
