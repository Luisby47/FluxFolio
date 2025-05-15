import { Controller } from "@hotwired/stimulus"

/**
 * Note Controller
 * 
 * This Stimulus controller manages note editing functionality with autosave support.
 * It handles character counting, validation, draft saving/loading, and status updates.
 * The controller provides a seamless note-taking experience with automatic background saving.
 */
export default class extends Controller {
  // DOM elements that can be targeted
  static targets = ["content", "charCount", "draftStatus", "discardButton"]
  
  // Values that can be passed from HTML
  static values = {
    maxLength: { type: Number, default: 1000 },  // Maximum character length for notes
    draftUrl: String,                            // API endpoint for draft operations
    draftInterval: { type: Number, default: 5000 }, // Autosave interval in milliseconds
  }

  /**
   * Initialize controller state
   */
  initialize() {
    this.draftExists = false
  }

  /**
   * Set up controller when connected to DOM
   */
  connect() {
    this.updateCharCount()
    this.loadDraft()
    this.startAutoSave()
  }

  /**
   * Clean up when disconnected from DOM
   */
  disconnect() {
    if (this.autoSaveInterval) {
      clearInterval(this.autoSaveInterval)
    }
  }

  /**
   * Update character count display and styling
   * Shows remaining characters and changes color when approaching limit
   */
  updateCharCount() {
    const remaining = this.maxLengthValue - this.contentTarget.value.length
    this.charCountTarget.textContent = `${remaining} characters remaining`

    // Change color to red when approaching character limit
    if (remaining < 50) {
      this.charCountTarget.classList.add("text-red-600", "dark:text-red-400")
      this.charCountTarget.classList.remove("text-gray-500", "dark:text-gray-400")
    } else {
      this.charCountTarget.classList.remove("text-red-600", "dark:text-red-400")
      this.charCountTarget.classList.add("text-gray-500", "dark:text-gray-400")
    }
  }

  /**
   * Validate note content for form submission
   * Checks for empty content and maximum length
   */
  validateContent() {
    const content = this.contentTarget.value.trim()
    if (content.length === 0) {
      this.contentTarget.setCustomValidity("Note content cannot be empty")
    } else if (content.length > this.maxLengthValue) {
      this.contentTarget.setCustomValidity(`Note content cannot exceed ${this.maxLengthValue} characters`)
    } else {
      this.contentTarget.setCustomValidity("")
    }
    this.contentTarget.reportValidity()
  }

  /**
   * Load saved draft content from the server
   * Populates form with draft content if available
   */
  async loadDraft() {
    try {
      const response = await fetch(this.draftUrlValue, {
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
      })

      if (response.ok) {
        const draft = await response.json()
        this.contentTarget.value = draft.content
        this.element.querySelector(`input[name="note[importance]"][value="${draft.importance}"]`).checked = true
        this.updateCharCount()
        this.updateDraftStatus("Draft loaded")
        this.draftExists = true
        if (this.hasDiscardButtonTarget) {
          this.discardButtonTarget.classList.remove("hidden")
        }
      }
    } catch (error) {
      console.error("Error loading draft:", error)
    }
  }

  /**
   * Start the autosave timer to periodically save drafts
   */
  startAutoSave() {
    this.autoSaveInterval = setInterval(() => {
      this.saveDraft()
    }, this.draftIntervalValue)
  }

  /**
   * Save current note content as a draft
   * Creates new draft or updates existing one
   */
  async saveDraft() {
    const content = this.contentTarget.value.trim()
    const importance = this.element.querySelector('input[name="note[importance]"]:checked')?.value || 5

    // Don't save empty drafts
    if (!content) return

    try {
      const method = this.draftExists ? "PATCH" : "POST"
      const response = await fetch(this.draftUrlValue, {
        method: method,
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
        body: JSON.stringify({
          note_draft: {
            content: content,
            importance: importance,
          },
        }),
      })

      if (response.ok) {
        this.draftExists = true
        this.updateDraftStatus("Draft saved")
        if (this.hasDiscardButtonTarget) {
          this.discardButtonTarget.classList.remove("hidden")
        }
      } else {
        this.updateDraftStatus("Error saving draft")
      }
    } catch (error) {
      console.error("Error saving draft:", error)
      this.updateDraftStatus("Error saving draft")
    }
  }

  /**
   * Discard the current draft and reset form
   * @param {Event} event - Click event
   */
  async discardDraft(event) {
    event.preventDefault()

    if (!this.draftExists) return

    try {
      const response = await fetch(this.draftUrlValue, {
        method: "DELETE",
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
      })

      if (response.ok) {
        // Reset form
        this.contentTarget.value = ""
        this.element.querySelector('input[name="note[importance]"][value="5"]').checked = true
        this.updateCharCount()
        this.updateDraftStatus("Draft discarded")
        this.draftExists = false
        if (this.hasDiscardButtonTarget) {
          this.discardButtonTarget.classList.add("hidden")
        }
      } else {
        this.updateDraftStatus("Error discarding draft")
      }
    } catch (error) {
      console.error("Error discarding draft:", error)
      this.updateDraftStatus("Error discarding draft")
    }
  }

  /**
   * Display draft status message temporarily
   * @param {string} message - Status message to display
   */
  updateDraftStatus(message) {
    if (this.hasDraftStatusTarget) {
      this.draftStatusTarget.textContent = message
      // Clear message after 2 seconds
      setTimeout(() => {
        this.draftStatusTarget.textContent = ""
      }, 2000)
    }
  }
}
