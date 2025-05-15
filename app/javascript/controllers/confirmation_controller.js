import { Controller } from "@hotwired/stimulus"

/**
 * Confirmation Controller
 * 
 * This Stimulus controller provides confirmation dialog functionality.
 * It intercepts actions like form submissions or link clicks and displays
 * a confirmation dialog before allowing the action to proceed.
 * 
 * Usage:
 * <a href="/delete" 
 *    data-controller="confirmation" 
 *    data-action="click->confirmation#confirm"
 *    data-confirm="Are you sure you want to delete this item?">Delete</a>
 */
export default class extends Controller {
  /**
   * Display a confirmation dialog and prevent the default action if user cancels
   * 
   * @param {Event} event - The triggering event (click, submit, etc.)
   */
  confirm(event) {
    // Get the confirmation message from data attribute or use a default
    const message = event.currentTarget.dataset.confirm || "Are you sure?"
    
    // Show browser's built-in confirmation dialog
    // If user clicks "Cancel", prevent the default action from happening
    if (!window.confirm(message)) {
      event.preventDefault()
    }
  }
} 