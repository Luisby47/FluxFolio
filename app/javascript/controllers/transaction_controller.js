import { Controller } from "@hotwired/stimulus"

/**
 * Transaction Controller
 * 
 * This Stimulus controller manages transaction form behavior.
 * It handles real-time calculations, validation, and updates for transaction forms
 * including computing total values, validating inputs, and populating current prices.
 */
export default class extends Controller {
  // Elements that can be targeted in the DOM
  static targets = [
    "units",        // Input field for number of units
    "unitPrice",    // Input field for price per unit
    "totalValue",   // Display element for total transaction value
    "type",         // Select field for transaction type (buy/sell)
    "currentPrice"  // Select field for investment with current price data
  ]

  /**
   * Set up initial calculations when controller connects to the DOM
   */
  connect() {
    this.calculateTotal()
  }

  /**
   * Calculate and display the total transaction value
   * Multiplies units by unit price and formats as currency
   */
  calculateTotal() {
    const units = parseFloat(this.unitsTarget.value) || 0
    const unitPrice = parseFloat(this.unitPriceTarget.value) || 0
    const total = units * unitPrice

    // Format the total as currency and update the display
    this.totalValueTarget.textContent = total.toLocaleString("en-US", {
      style: "currency",
      currency: "USD",
    })
  }

  /**
   * Validate that units value is positive
   * Called when units input changes
   */
  validateUnits() {
    const units = parseFloat(this.unitsTarget.value)
    if (units <= 0) {
      // Set custom validation message for invalid input
      this.unitsTarget.setCustomValidity("Units must be greater than 0")
    } else {
      // Clear validation message for valid input
      this.unitsTarget.setCustomValidity("")
    }
    // Show validation message if invalid
    this.unitsTarget.reportValidity()
    // Update total value calculation
    this.calculateTotal()
  }

  /**
   * Validate that unit price value is positive
   * Called when unit price input changes
   */
  validateUnitPrice() {
    const unitPrice = parseFloat(this.unitPriceTarget.value)
    if (unitPrice <= 0) {
      // Set custom validation message for invalid input
      this.unitPriceTarget.setCustomValidity("Unit price must be greater than 0")
    } else {
      // Clear validation message for valid input
      this.unitPriceTarget.setCustomValidity("")
    }
    // Show validation message if invalid
    this.unitPriceTarget.reportValidity()
    // Update total value calculation
    this.calculateTotal()
  }

  /**
   * Update the unit price field with the current market price of the selected investment
   * Called when investment selection changes
   */
  updateCurrentPrice() {
    const target = this.currentPriceTarget
    // Get the selected option element
    const selectedOption = target.querySelector(`option[value="${target.value}"]`)
    // Extract current price from data attribute
    const currentPrice = parseFloat(selectedOption ? selectedOption.dataset.currentPrice : target.dataset.currentPrice)
    
    // Update the unit price field if it exists
    if (this.hasUnitPriceTarget) {
      this.unitPriceTarget.value = currentPrice
      this.calculateTotal()
    }
  }
}
