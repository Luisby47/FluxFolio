# TransactionsController manages transaction-related actions
# This controller handles CRUD operations for investment transactions
# and data export functionality
class TransactionsController < ApplicationController
  # Set up portfolio for all actions 
  before_action :set_portfolio
  # Set up investment for specific actions
  before_action :set_investment, only: [ :index, :edit, :update, :destroy, :export ]
  # Set up transaction for edit, update, and destroy actions
  before_action :set_transaction, only: [ :edit, :update, :destroy ]

  # GET /portfolios/:portfolio_id/investments/:investment_id/transactions
  # List all transactions for a specific investment with export options
  def index
    @transactions = @investment.transactions.order(transaction_date: :desc)

    respond_to do |format|
      format.html { render }
      # Export to CSV format
      format.csv { send_data @transactions.to_csv, filename: "#{@investment.name}-transactions-#{Date.current}.csv" }
      # Export to JSON format
      format.json { send_data @transactions.to_json_export, filename: "#{@investment.name}-transactions-#{Date.current}.json" }
    end
  end

  # GET /portfolios/:portfolio_id/investments/:investment_id/transactions/new
  # OR /portfolios/:portfolio_id/transactions/new
  # Display form for creating a new transaction
  def new
    @transaction = if params[:investment_id]
      # We are on the investment page so we know the investment
      @investment = @portfolio.investments.find(params[:investment_id])
      @investment.transactions.build
    else
      # From the portfolio page
      @investment = nil
      Transaction.new
    end
  end

  # POST /portfolios/:portfolio_id/investments/:investment_id/transactions
  # OR /portfolios/:portfolio_id/transactions
  # Create a new transaction with the provided parameters
  def create
    @transaction = if params[:investment_id]
      @investment = @portfolio.investments.find(params[:investment_id])
      @investment.transactions.build(transaction_params)
    else
      @investment = @portfolio.investments.find(transaction_params[:investment_id])
      @investment.transactions.build(transaction_params)
    end

    if @transaction.save
      respond_to do |format|
        # HTML response redirects to the investment show page
        format.html { redirect_to portfolio_investment_path(@portfolio, @investment), notice: "Transaction was successfully created." }
        # Turbo Stream response updates the UI without a full page reload
        format.turbo_stream do
          replace_turbo_stream("Transaction was successfully created.")
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /portfolios/:portfolio_id/investments/:investment_id/transactions/:id/edit
  # Display form for editing an existing transaction
  def edit
  end

  # PATCH/PUT /portfolios/:portfolio_id/investments/:investment_id/transactions/:id
  # Update an existing transaction with the provided parameters
  def update
    if @transaction.update(transaction_params)
      respond_to do |format|
        # HTML response redirects to the investment show page
        format.html { redirect_to portfolio_investment_path(@portfolio, @investment), notice: "Transaction was successfully updated." }
        # Turbo Stream response updates the UI without a full page reload
        format.turbo_stream do
          replace_turbo_stream("Transaction was successfully updated.")
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /portfolios/:portfolio_id/investments/:investment_id/transactions/:id
  # Remove a transaction from the database
  def destroy
    @transaction.destroy
    respond_to do |format|
      # HTML response redirects to the investment show page
      format.html { redirect_to portfolio_investment_path(@portfolio, @investment), notice: "Transaction was successfully deleted." }
      # Turbo Stream response updates the UI without a full page reload
      format.turbo_stream do
        replace_turbo_stream("Transaction was successfully deleted.")
      end
    end
  end

  # GET /portfolios/:portfolio_id/investments/:investment_id/transactions/export
  # Export transactions for a specific date range
  def export
    # Parse start date from parameters or default to 30 days ago
    start_date = params[:start_date].present? ? Time.zone.parse(params[:start_date]) : 30.days.ago.beginning_of_day
    @transactions = @investment.transactions.where("transaction_date >= ?", start_date).order(transaction_date: :desc)
    @date_range_options = Transaction.date_range_options

    respond_to do |format|
      format.html
      format.turbo_stream
      # Export to CSV format with date range in filename
      format.csv { send_data @transactions.to_csv, filename: "#{@investment.name}-transactions-#{start_date.to_date}-#{Date.current}.csv" }
      # Export to JSON format with date range in filename
      format.json { send_data @transactions.to_json_export, filename: "#{@investment.name}-transactions-#{start_date.to_date}-#{Date.current}.json" }
    end
  end

  private

    # Helper method to render consistent Turbo Stream responses for CRUD actions
    # Updates the transactions table, investment performance, and portfolio analytics
    def replace_turbo_stream(message)
      render turbo_stream: [
        close_modal_turbo_stream,
        flash_turbo_stream_message("notice", message),
        # Update transactions table with current data
        turbo_stream.replace("transactions_table",
          partial: "investments/transactions",
          locals: { portfolio: @portfolio, investment: @investment, transactions: @investment.transactions }
        ),
        # Update investment performance metrics
        turbo_stream.replace("investment_performance",
          partial: "investments/performance",
          locals: { investment: @investment }
        ),
        # Update portfolio analytics charts with new data
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
      @investment = @portfolio.investments.find(params[:investment_id])
    end

    # Find the requested transaction within the investment
    def set_transaction
      @transaction = @investment.transactions.find(params[:id])
    end

    # Define permitted parameters for transaction actions
    def transaction_params
      params.require(:transaction).permit(:transaction_date, :transaction_type, :units, :unit_price, :investment_id, :id)
    end
end
