# NotesController manages note-related actions
# This controller handles CRUD operations for notes attached to portfolios or investments
# It uses polymorphic associations to handle notes for different notable types
class NotesController < ApplicationController
  # Set up the notable object (portfolio or investment) that the note belongs to
  before_action :set_notable
  # Set up the note for edit, update, and destroy actions
  before_action :set_note, only: [ :edit, :update, :destroy ]

  # GET /portfolios/:portfolio_id/notes/new
  # OR /portfolios/:portfolio_id/investments/:investment_id/notes/new
  # Display form for creating a new note, potentially populating from a draft
  def new
    @note = if (draft = Current.user.note_drafts.find_by(notable: @notable))
      # Convert the draft to a note if one exists
      draft.to_note
    else
      # Otherwise create a new note
      @notable.notes.build
    end
  end

  # POST /portfolios/:portfolio_id/notes
  # OR /portfolios/:portfolio_id/investments/:investment_id/notes
  # Create a new note with the provided parameters
  def create
    @note = @notable.notes.build(note_params)

    if @note.save
      # Delete any existing draft for this notable after saving the note
      Current.user.note_drafts.find_by(notable: @notable)&.destroy
      set_notable
      respond_to do |format|
        # Turbo Stream response updates the UI without a full page reload
        format.turbo_stream {
          render_turbo_stream("Note was successfully created.")
        }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /portfolios/:portfolio_id/notes/:id/edit
  # OR /portfolios/:portfolio_id/investments/:investment_id/notes/:id/edit
  # Display form for editing an existing note
  def edit
  end

  # PATCH/PUT /portfolios/:portfolio_id/notes/:id
  # OR /portfolios/:portfolio_id/investments/:investment_id/notes/:id
  # Update an existing note with the provided parameters
  def update
    if @note.update(note_params)
      set_notable
      respond_to do |format|
        # Turbo Stream response updates the UI without a full page reload
        format.turbo_stream {
          render_turbo_stream("Note was successfully updated.")
        }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /portfolios/:portfolio_id/notes/:id
  # OR /portfolios/:portfolio_id/investments/:investment_id/notes/:id
  # Remove a note from the database
  def destroy
    @note.destroy
    set_notable
    respond_to do |format|
      # HTML response redirects to the notable's show page
      format.html { redirect_to polymorphic_path([ @portfolio, @notable ]), notice: "Note was successfully deleted." }
      # Turbo Stream response updates the UI without a full page reload
      format.turbo_stream {
        render_turbo_stream("Note was successfully deleted.")
      }
    end
  end

  private

    # Helper method to render consistent Turbo Stream responses for CRUD actions
    # Updates the notes section in the UI
    def render_turbo_stream(message)
      set_notable
      # Should be "portfolios" or "investments"
      path_prefix = @notable.class.name.downcase.pluralize
      render turbo_stream: [
        close_modal_turbo_stream,
        flash_turbo_stream_message("notice", message),
        # Update notes section with current notes
        turbo_stream.replace("notes-section",
          partial: "#{path_prefix}/notes_section",
          locals: { portfolio: params[:portfolio_id], investment: params[:investment_id], notes: @notes }
        )
      ]
    end

    # Determine the notable object (portfolio or investment) based on parameters
    # This supports the polymorphic nature of notes
    def set_notable
      if params[:investment_id].present?
        # If investment_id is present, the note belongs to an investment
        @portfolio = Current.user.portfolios.find(params[:portfolio_id])
        @notable = @portfolio.investments.find(params[:investment_id])
      elsif params[:portfolio_id].present?
        # If only portfolio_id is present, the note belongs to a portfolio
        @notable = Current.user.portfolios.find(params[:portfolio_id])
      end

      @notes = @notable.notes
    end

    # Find the requested note within the notable object
    def set_note
      @note = @notable.notes.find(params[:id])
    end

    # Define permitted parameters for note actions
    def note_params
      params.require(:note).permit(:content, :importance)
    end
end
