import { Application } from "@hotwired/stimulus"

/**
 * Stimulus Application Initialization
 * 
 * This file initializes the Stimulus application and configures its behavior.
 * Stimulus is a JavaScript framework that enhances HTML by connecting DOM elements
 * to JavaScript objects automatically through data-controller attributes.
 */

// Initialize Stimulus application
const application = Application.start()

// Configure Stimulus development experience
// When debug is true, Stimulus will log actions to the console
application.debug = false

// Make Stimulus available globally for debugging in browser console
window.Stimulus = application

// Export application for importing in other files
export { application }
