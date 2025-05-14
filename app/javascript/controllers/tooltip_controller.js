import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tooltip"
export default class extends Controller {
  static targets = ["content"]
  static values = {
    position: { type: String, default: "top" }
  }
  
  connect() {
    // Position the tooltip based on the position value
    this.positionTooltip()
  }
  
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
        tooltipContent.classList.add("bottom-full", "mb-2", "left-1/2", "-translate-x-1/2")
        break
      case "bottom":
        tooltipContent.classList.add("top-full", "mt-2", "left-1/2", "-translate-x-1/2")
        break
      case "left":
        tooltipContent.classList.add("right-full", "mr-2", "top-1/2", "-translate-y-1/2")
        break
      case "right":
        tooltipContent.classList.add("left-full", "ml-2", "top-1/2", "-translate-y-1/2")
        break
    }
  }
  
  show() {
    this.contentTarget.classList.remove("opacity-0", "invisible")
    this.contentTarget.classList.add("opacity-100", "visible")
  }
  
  hide() {
    this.contentTarget.classList.remove("opacity-100", "visible")
    this.contentTarget.classList.add("opacity-0", "invisible")
  }
} 