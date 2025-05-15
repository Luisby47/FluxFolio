import { Controller } from "@hotwired/stimulus"

/**
 * Dropdown Controller
 * 
 * This Stimulus controller manages dropdown menu functionality.
 * It handles showing/hiding the dropdown menu, and automatically
 * closes the dropdown when clicking outside of it.
 * 
 * Usage:
 * <div data-controller="dropdown">
 *   <button data-action="dropdown#toggle">Menu</button>
 *   <div data-dropdown-target="menu" class="hidden">
 *     <!-- Dropdown content -->
 *   </div>
 * </div>
 */
export default class extends Controller {
  // Elements that can be targeted in the DOM
  static targets = ["menu"] // The dropdown menu element that will be shown/hidden
  
  /**
   * Set up event listeners when controller connects to the DOM
   */
  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', this.handleClickOutside.bind(this))
  }
  
  /**
   * Clean up event listeners when controller disconnects from the DOM
   */
  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this))
  }
  
  /**
   * Toggle the visibility of the dropdown menu
   * 
   * @param {Event} event - Click event from the trigger element
   */
  toggle(event) {
    // Prevent the click from propagating to the document
    // (which would immediately close the dropdown via handleClickOutside)
    event.stopPropagation()
    
    // Toggle the 'hidden' class to show/hide the menu
    this.menuTarget.classList.toggle('hidden')
  }
  
  /**
   * Handle clicks outside the dropdown to automatically close it
   * 
   * @param {Event} event - Click event from anywhere in the document
   */
  handleClickOutside(event) {
    // Check if the click was outside the dropdown component
    // and the menu is currently visible
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains('hidden')) {
      // Hide the dropdown menu
      this.menuTarget.classList.add('hidden')
    }
  }
} 