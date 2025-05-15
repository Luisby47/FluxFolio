# NoteDraftsController manages draft note functionality
# This controller handles CRUD operations for note drafts, which are unsaved notes
# that can be automatically saved and restored during the editing process
# It supports JSON responses for AJAX requests from the note editor
class NoteDraftsController < ApplicationController
  # Set up the notable object (portfolio or investment) that the draft belongs to
  before_action :set_notable
  # Set up the note draft for show, update, and destroy actions
  before_action :set_note_draft, only: [ :show, :update, :destroy ]

  # GET /portfolios/:portfolio_id/note_draft
  # OR /portfolios/:portfolio_id/investments/:investment_id/note_draft
  # Retrieve an existing draft note for the notable object
  def show
    respond_to do |format|
      # Return draft data as JSON for the note editor
      format.json { render json: @note_draft }
    end
  end

  # POST /portfolios/:portfolio_id/note_draft
  # OR /portfolios/:portfolio_id/investments/:investment_id/note_draft
  # Create a new draft note for the notable object
  def create
    # Build a new draft associated with the current user and notable object
    @note_draft = Current.user.note_drafts.build(note_draft_params.merge(notable: @notable))

    respond_to do |format|
      if @note_draft.save
        # Return the created draft as JSON with 201 Created status
        format.json { render json: @note_draft, status: :created }
      else
        # Return validation errors as JSON
        format.json { render json: @note_draft.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /portfolios/:portfolio_id/note_draft
  # OR /portfolios/:portfolio_id/investments/:investment_id/note_draft
  # Update an existing draft note with latest content
  def update
    respond_to do |format|
      if @note_draft.update(note_draft_params)
        # Return the updated draft as JSON
        format.json { render json: @note_draft }
      else
        # Return validation errors as JSON
        format.json { render json: @note_draft.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /portfolios/:portfolio_id/note_draft
  # OR /portfolios/:portfolio_id/investments/:investment_id/note_draft
  # Remove a draft note from the database
  def destroy
    @note_draft.destroy
    respond_to do |format|
      # Return 204 No Content for successful deletion
      format.json { head :no_content }
    end
  end

  private

    # Determine the notable object (portfolio or investment) based on parameters
    # This supports the polymorphic nature of note drafts
    def set_notable
      if params[:investment_id].present?
        # If investment_id is present, the draft belongs to an investment
        portfolio = Current.user.portfolios.find(params[:portfolio_id])
        @notable = portfolio.investments.find(params[:investment_id])
      elsif params[:portfolio_id].present?
        # If only portfolio_id is present, the draft belongs to a portfolio
        @notable = Current.user.portfolios.find(params[:portfolio_id])
      end
    end

    # Find the note draft for the current user and notable object
    # Note that a user can only have one draft per notable object
    def set_note_draft
      @note_draft = Current.user.note_drafts.find_by!(notable: @notable)
    end

    # Define permitted parameters for note draft actions
    def note_draft_params
      params.require(:note_draft).permit(:content, :importance)
    end
end
