import { Controller } from "@hotwired/stimulus"

/**
 * Tooltip Controller
 * 
 * This Stimulus controller manages tooltip functionality in the application.
 * It handles positioning, showing, and hiding of tooltips with smooth transitions.
 * Tooltips can be positioned in four directions: top, bottom, left, or right.
 */
export default class extends Controller {
  // Elements that can be targeted in the DOM
  static targets = ["content"] // The tooltip content element
  
  // Values that can be passed from HTML
  static values = {
    position: { type: String, default: "top" } // Position of tooltip relative to parent (top, bottom, left, right)
  }
  
  /**
   * Initialize tooltip when controller connects to the DOM
   * Sets up initial positioning
   */
  connect() {
    // Position the tooltip based on the position value
    this.positionTooltip()
  }
  
  /**
   * Positions the tooltip based on the specified position value
   * Applies appropriate CSS classes to achieve desired positioning
   */
  positionTooltip() {
    const position = this.positionValue
    const tooltipContent = this.contentTarget
    
    // Reset all position classes
    tooltipContent.classList.remove(
      "bottom-full", "top-full", "left-full", "right-full",
      "mb-2", "mt-2", "mr-2", "ml-2"
    )
    
    // Apply appropriate position classes
    switch (position) {
      case "top":
        // Position above the element with margin bottom
        tooltipContent.classList.add("bottom-full", "mb-2", "left-1/2", "-translate-x-1/2")
        break
      case "bottom":
        // Position below the element with margin top
        tooltipContent.classList.add("top-full", "mt-2", "left-1/2", "-translate-x-1/2")
        break
      case "left":
        // Position to the left of the element with margin right
        tooltipContent.classList.add("right-full", "mr-2", "top-1/2", "-translate-y-1/2")
        break
      case "right":
        // Position to the right of the element with margin left
        tooltipContent.classList.add("left-full", "ml-2", "top-1/2", "-translate-y-1/2")
        break
    }
  }
  
  /**
   * Show the tooltip with a fade-in animation
   * Called on mouseenter or focus events
   */
  show() {
    this.contentTarget.classList.remove("opacity-0", "invisible")
    this.contentTarget.classList.add("opacity-100", "visible")
  }
  
  /**
   * Hide the tooltip with a fade-out animation
   * Called on mouseleave or blur events
   */
  hide() {
    this.contentTarget.classList.remove("opacity-100", "visible")
    this.contentTarget.classList.add("opacity-0", "invisible")
  }
} 