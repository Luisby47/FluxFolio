# InvestmentsController manages investment-related actions
# This controller handles CRUD operations for investments within portfolios
class InvestmentsController < ApplicationController
  # Set up portfolio for all actions (investments are nested under portfolios)
  before_action :set_portfolio
  # Set up investment for all actions except new and create
  before_action :set_investment, except: [ :new, :create ]

  # GET /portfolios/:portfolio_id/investments/:id
  # Display details for a specific investment including transactions and notes
  def show
    @transactions = @investment.transactions.order(transaction_date: :desc)
    @notes = @investment.notes.order(importance: :asc, created_at: :desc)
  end

  # GET /portfolios/:portfolio_id/investments/new
  # Display form for creating a new investment within a portfolio
  def new
    @investment = @portfolio.investments.build
  end

  # POST /portfolios/:portfolio_id/investments
  # Create a new investment with the provided parameters
  def create
    @investment = @portfolio.investments.build(investment_params)

    if @investment.save
      respond_to do |format|
        # HTML response redirects to the portfolio show page
        format.html { redirect_to portfolio_path(@portfolio), notice: "Investment was successfully created." }
        # Turbo Stream response updates the UI without a full page reload
        format.turbo_stream {
          render_turbo_stream("Investment was successfully created.")
        }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /portfolios/:portfolio_id/investments/:id/edit
  # Display form for editing an existing investment
  def edit
  end

  # PATCH/PUT /portfolios/:portfolio_id/investments/:id
  # Update an existing investment with the provided parameters
  def update
    if @investment.update(investment_params)
      respond_to do |format|
        # HTML response redirects to the portfolio show page
        format.html { redirect_to portfolio_path(@portfolio), notice: "Investment was successfully updated." }
        # Turbo Stream response updates the UI without a full page reload
        format.turbo_stream {
          render_turbo_stream("Investment was successfully updated.")
        }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /portfolios/:portfolio_id/investments/:id
  # Remove an investment and its associated records from the database
  def destroy
    @investment.destroy
    respond_to do |format|
      # HTML response redirects to the portfolio show page
      format.html { redirect_to portfolio_path(@portfolio), notice: "Investment was successfully deleted." }
      # Turbo Stream response updates the UI without a full page reload
      format.turbo_stream {
        render_turbo_stream("Investment was successfully deleted.")
      }
    end
  end

  private

    # Helper method to render consistent Turbo Stream responses for CRUD actions
    # Updates the investments table and analytics sections in the UI
    def render_turbo_stream(message)
      render turbo_stream: [
        close_modal_turbo_stream,
        flash_turbo_stream_message("notice", message),
        # Update investments table with the current investments
        turbo_stream.replace("investments_table",
          partial: "portfolios/investments_table",
          locals: { portfolio: @portfolio, investments: @portfolio.investments.order(:name) }
        ),
        # Update analytics charts with new data
        turbo_stream.replace("analytics",
          partial: "portfolios/analytics",
          locals: { portfolio: @portfolio }
        )
      ]
    end

    # Find the requested portfolio for the current user
    def set_portfolio
      @portfolio = Current.user.portfolios.find(params[:portfolio_id])
    end

    # Find the requested investment within the portfolio
    def set_investment
      @investment = @portfolio.investments.find(params[:id])
    end

    # Define permitted parameters for investment actions
    def investment_params
      params.require(:investment).permit(:name, :symbol, :investment_type, :status, :current_unit_price, :exit_target_type)
    end
end
