import { Controller } from "@hotwired/stimulus"

/**
 * Form Controller
 * 
 * This Stimulus controller provides utility functions for form handling.
 * It allows triggering form submission programmatically from non-submit
 * elements like links or buttons outside the form.
 * 
 * Usage:
 * <form data-controller="form" id="my-form">
 *   <!-- form fields -->
 * </form>
 * <a href="#" data-action="form#submit">Submit form</a>
 */
export default class extends Controller {
  /**
   * Programmatically submit the form element
   * Can be triggered by any element with a data-action pointing to this method
   * 
   * @param {Event} event - The triggering event
   */
  submit(event) {
    // requestSubmit() is used instead of submit() to trigger form validation
    // and the submit event, allowing other event handlers to intercept if needed
    this.element.requestSubmit()
  }
}
