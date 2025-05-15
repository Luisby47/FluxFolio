import { Controller } from "@hotwired/stimulus"

/**
 * Investments Table Controller
 * 
 * This Stimulus controller manages the investments table behavior,
 * particularly the ability to toggle visibility of zero-unit investments.
 * It persists the user's preference in localStorage and applies it consistently.
 */
export default class extends Controller {
  // Elements that can be targeted in the DOM
  static targets = ["row"] // Investment table rows
  
  // Values that can be passed from HTML or set programmatically
  static values = {
    hideZeroUnits: { type: Boolean, default: false }, // Whether to hide investments with zero units
  }

  /**
   * Initialize the table when controller connects to the DOM
   * Loads saved preference from localStorage
   */
  connect() {
    // Load preference from localStorage
    const hideZeroUnits = localStorage.getItem("hideZeroUnits") === "true"
    this.hideZeroUnitsValue = hideZeroUnits
    // Apply the preference to the table
    this.updateVisibility()
  }

  /**
   * Toggle the visibility of zero-unit investments
   * Called when user clicks the toggle button/checkbox
   */
  toggle() {
    // Invert the current preference
    this.hideZeroUnitsValue = !this.hideZeroUnitsValue
    // Save the new preference to localStorage
    localStorage.setItem("hideZeroUnits", this.hideZeroUnitsValue)
    // Apply the preference to the table
    this.updateVisibility()
  }

  /**
   * Update the visibility of investment rows based on current preference
   * Hides or shows zero-unit investments accordingly
   */
  updateVisibility() {
    this.rowTargets.forEach((row) => {
      // Get the number of units from the row's data attribute
      const units = parseFloat(row.dataset.units)
      // If units is zero, toggle visibility based on hideZeroUnits preference
      if (units === 0) {
        row.classList.toggle("hidden", this.hideZeroUnitsValue)
      }
    })
  }
}
