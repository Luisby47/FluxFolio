import { Controller } from "@hotwired/stimulus"

/**
 * Theme Controller
 * 
 * This Stimulus controller manages the application's theme switching functionality.
 * It supports dark/light mode toggle, persists user preferences in localStorage,
 * and respects the user's system preferences when no explicit choice is made.
 * 
 * The controller uses CSS classes on the document's root element to apply theming.
 */
export default class extends Controller {
  /**
   * Initialize theme settings when controller connects to the DOM
   * Determines initial theme based on localStorage or system preferences
   */
  connect() {
    const darkIcon = this.element.querySelector("#theme-toggle-dark-icon")
    const lightIcon = this.element.querySelector("#theme-toggle-light-icon")

    // Determine if dark mode should be active based on:
    // 1. Previously saved preference in localStorage, or
    // 2. System preference if no saved preference exists
    if (
      localStorage.getItem("color-theme") === "dark" ||
      (!("color-theme" in localStorage) && window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      // Apply dark mode
      document.documentElement.classList.add("dark")
      lightIcon.classList.remove("hidden") // Show light icon (for switching to light mode)
    } else {
      // Apply light mode
      document.documentElement.classList.remove("dark")
      darkIcon.classList.remove("hidden") // Show dark icon (for switching to dark mode)
    }
  }

  /**
   * Toggle between light and dark modes
   * Updates UI, applies theme changes, and saves preference
   */
  toggle() {
    const darkIcon = this.element.querySelector("#theme-toggle-dark-icon")
    const lightIcon = this.element.querySelector("#theme-toggle-light-icon")

    // Toggle visibility of theme icons
    darkIcon.classList.toggle("hidden")
    lightIcon.classList.toggle("hidden")

    // Handle theme toggle based on current state
    if (localStorage.getItem("color-theme")) {
      // If we have a saved preference
      if (localStorage.getItem("color-theme") === "light") {
        // Switch from light to dark
        document.documentElement.classList.add("dark")
        localStorage.setItem("color-theme", "dark")
      } else {
        // Switch from dark to light
        document.documentElement.classList.remove("dark")
        localStorage.setItem("color-theme", "light")
      }
    } else {
      // If no saved preference exists yet
      if (document.documentElement.classList.contains("dark")) {
        // Currently dark, switch to light
        document.documentElement.classList.remove("dark")
        localStorage.setItem("color-theme", "light")
      } else {
        // Currently light, switch to dark
        document.documentElement.classList.add("dark")
        localStorage.setItem("color-theme", "dark")
      }
    }
  }
}
