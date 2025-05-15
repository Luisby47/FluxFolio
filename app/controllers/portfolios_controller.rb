require "httparty"
require "nokogiri"

# PortfoliosController manages portfolio-related actions
# This controller handles CRUD operations for portfolios and includes functionality
# to refresh investment prices from external sources
class PortfoliosController < ApplicationController
  # Set up portfolio for specific actions
  before_action :set_portfolio, only: [ :show, :edit, :update, :destroy, :refresh_investment_prices ]
  # Load all portfolios for the current user for specific actions
  before_action :set_portfolios, only: [ :index, :create, :destroy ]

  # GET /portfolios
  # Display a list of the user's portfolios
  def index
  end

  # GET /portfolios/:id
  # Show details for a specific portfolio including its investments and notes
  def show
    @investments = @portfolio.investments.includes(:transactions).order(:name)
    @notes = @portfolio.notes.order(importance: :asc, created_at: :desc)
  end

  # GET /portfolios/new
  # Display form for creating a new portfolio
  def new
    @portfolio = Current.user.portfolios.build
  end

  # POST /portfolios
  # Create a new portfolio with the provided parameters
  def create
    @portfolio = Current.user.portfolios.build(portfolio_params)

    if @portfolio.save
      respond_to do |format|
        # HTML response redirects to the portfolio show page
        format.html { redirect_to @portfolio, notice: "Portfolio was successfully created." }
        # Turbo Stream response updates the UI without a full page reload
        format.turbo_stream {
          render_create_destroy_turbo_stream("Portfolio was successfully created.")
        }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /portfolios/:id/edit
  # Display form for editing an existing portfolio
  def edit
  end

  # PATCH/PUT /portfolios/:id
  # Update an existing portfolio with the provided parameters
  def update
    if @portfolio.update(portfolio_params)
      respond_to do |format|
        # HTML response redirects to the portfolio show page
        format.html { redirect_to @portfolio, notice: "Portfolio was successfully updated." }
        # Turbo Stream response updates the UI without a full page reload
        format.turbo_stream {
          render turbo_stream: [
            close_modal_turbo_stream,
            flash_turbo_stream_message("notice", "Portfolio was successfully updated."),
            turbo_stream.replace("portfolio_#{@portfolio.id}",
              partial: "portfolios/portfolio_header_tag",
              locals: { portfolio: @portfolio }
            )
          ]
        }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /portfolios/:id
  # Remove a portfolio and its associated records from the database
  def destroy
    @portfolio.destroy
    respond_to do |format|
      format.turbo_stream {
        render_create_destroy_turbo_stream("Portfolio was successfully deleted.")
      }
    end
  end

  # POST /portfolios/:id/refresh_investment_prices
  # Fetch current market prices for all investments in the portfolio
  def refresh_investment_prices
    @portfolio.investments.each do |investment|
      begin
        # Set default symbols for common investments that might not have symbols
        if investment.symbol.blank?
          investment.symbol = "GC=F" if investment.name.upcase == "GOLD"
          investment.symbol = "SI=F" if investment.name.upcase == "SILVER"
          investment.symbol = "BTC-USD" if investment.name.upcase == "BITCOIN"
          investment.symbol = "ETH-USD" if investment.name.upcase == "ETHEREUM"
        end
        
        # Fetch price from Yahoo Finance if symbol is available
        if investment.symbol.present?
          response = fetch_current_price(investment.symbol.upcase)
          # Only update if new price is different from current price
          investment.update(current_unit_price: response[:price],
            current_price_change: response[:change_amount],
            current_price_change_percent: response[:change_percent]) if response[:price].present? && response[:price] != investment.current_unit_price
        end
      rescue => e
        Rails.logger.error "Failed to update price for #{investment.symbol}: #{e.message}"
      end
    end

    # Update UI with new price data using Turbo Streams
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          # Update investments table with new prices
          turbo_stream.replace("investments_table",
            partial: "investments_table",
            locals: { portfolio: @portfolio, investments: @portfolio.investments.order(:name) }
          ),
          # Update portfolio performance metrics
          turbo_stream.replace("portfolio_performance",
            partial: "portfolio_performance",
            locals: { portfolio: @portfolio }
          ),
          # Update portfolio analytics charts
          turbo_stream.replace("analytics",
            partial: "analytics",
            locals: { portfolio: @portfolio }
          ),
          # Show success message
          flash_turbo_stream_message("notice", "Investment prices have been refreshed.")
        ]
      }
    end
  end

  private

    # Helper method to render consistent Turbo Stream responses for create/destroy actions
    def render_create_destroy_turbo_stream(message)
      render turbo_stream: [
        close_modal_turbo_stream,
        flash_turbo_stream_message("notice", message),
        # Update the portfolios list
        turbo_stream.replace("portfolios",
          partial: "portfolios/portfolios",
          locals: { portfolios: @portfolios }
        ),
        # Update the portfolio selector dropdown
        turbo_stream.replace("portfolio_select",
          partial: "shared/portfolio_select",
        )
      ]
    end

    # Load all portfolios for the current user with their investments
    def set_portfolios
      @portfolios = Current.user.portfolios.includes(:investments)
    end

    # Find the requested portfolio for the current user
    def set_portfolio
      @portfolio = Current.user.portfolios.find(params[:id])
    end

    # Define permitted parameters for portfolio actions
    def portfolio_params
      params.require(:portfolio).permit(:name)
    end

    # Fetch current price data from Yahoo Finance
    # Uses web scraping to get real-time data for a given investment symbol
    def fetch_current_price(symbol)
      url = "https://finance.yahoo.com/quote/#{symbol}/?p=#{symbol}"

      Rails.logger.info "Refresh price url: #{url}"

      # Set headers to mimic a browser request
      headers = {
        "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        "Cache-Control" => "no-cache",
        "Pragma" => "no-cache",
        "accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "Accept-Language" => "en-US,en;q=0.9",
        "Accept-Encoding" => "gzip, deflate, br",
        ":authority" => "finance.yahoo.com",
        ":method" => "GET",
        ":path" => "/quote/#{symbol}/?p=#{symbol}",
        ":scheme" => "https"
      }

      # Fetch HTML content from Yahoo Finance
      response = HTTParty.get(url, headers: headers)
      doc = Nokogiri::HTML(response.body)

      # Extract price data using XPath selectors
      price_nodes = doc.xpath("//span[@data-testid='qsp-price']")
      price = price_nodes.any? && price_nodes.first.text.present? ? price_nodes.first.text.gsub(",", "") : nil

      change_amount_nodes = doc.xpath("//span[@data-testid='qsp-price-change']")
      change_percent_nodes = doc.xpath("//span[@data-testid='qsp-price-change-percent']")

      change_amount = change_amount_nodes.any? && change_amount_nodes.first.text.present? ? change_amount_nodes.first.text.gsub(",", "") : nil
      change_percent = change_percent_nodes.any? && change_percent_nodes.first.text.present? ? change_percent_nodes.first.text.gsub(",", "") : nil

      # Prepare data object with price information
      data ={ price: price, change_amount: change_amount, change_percent: change_percent } if price.present?

      Rails.logger.info "Refresh price data: #{data.inspect}"

      return data if price.present?

      raise "unable to fetch price for #{symbol}"
    rescue => e
      raise "Failed to fetch price: #{e.message}"
    end
end
