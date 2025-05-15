# Portfolio model represents an investment portfolio belonging to a user
# It handles portfolio management, performance calculations, and analytics
class Portfolio < ApplicationRecord
  # Relationships
  belongs_to :user
  has_many :investments, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy
  has_many :transactions, through: :investments

  # Validations
  validates :name, presence: true

  # Calculate data for asset allocation chart/visualization
  # Returns a hash with labels and values for rendering charts
  def allocation_data
    # Only include investments with positive value
    valid_investments = investments.select { |i| i.current_value.to_f > 0 }

    # Return empty data if no valid investments
    return { labels: [], values: [] } if valid_investments.empty?

    # Calculate total portfolio value for percentage calculation
    total_value = valid_investments.sum(&:current_value)

    # Map investments to data points
    investment_data = valid_investments.map do |investment|
      percentage = (investment.current_value / total_value) * 100
      {
        label: "#{investment.name} (#{number_to_percentage(percentage, precision: 1)})",
        value: investment.current_value.to_f
      }
    end

    # Sort by value descending
    investment_data.sort_by! { |d| -d[:value] }

    {
      labels: investment_data.map { |d| d[:label] },
      values: investment_data.map { |d| d[:value] }
    }
  end

  # Calculate historical performance data for a given time period
  # days: Number of days to look back (default: 30)
  # Returns a hash with labels (dates) and values (portfolio value at each date)
  def performance_data(days = 30)
    start_date = days.days.ago.beginning_of_day
    dates = (start_date.to_date..Date.current).to_a

    # Calculate portfolio value for each date
    data_points = dates.map do |date|
      value = investments.sum do |investment|
        investment.calculate_value_at_date(date)
      end
      [ date, value ]
    end

    {
      labels: data_points.map { |date, _| date.strftime("%Y-%m-%d") },
      values: data_points.map { |_, value| value }
    }
  end

  # Calculate total current value of all investments in the portfolio
  def total_value
    investments.sum(&:current_value)
  end

  # Calculate total cost basis of all investments in the portfolio
  def total_cost
    investments.sum(&:total_cost)
  end

  # Calculate total return percentage for the portfolio
  # (Total gain or loss divided by total cost)
  def total_return
    return 0 if total_cost.zero?
    total_gain_loss / total_cost
  end

  # Calculate total realized gain/loss across all investments
  # (Gains/losses from closed positions)
  def realized_gain_loss
    investments.sum(&:realized_gain_loss)
  end

  # Calculate total unrealized gain/loss across all investments
  # (Gains/losses from current open positions)
  def unrealized_gain_loss
    investments.sum(&:unrealized_gain_loss)
  end

  # Calculate combined total gain/loss (realized + unrealized)
  def total_gain_loss
    realized_gain_loss + unrealized_gain_loss
  end

  private

    # Helper method to format percentages for display
    def number_to_percentage(number, options = {})
      precision = options.fetch(:precision, 1)
      "#{number.round(precision)}%"
    end
end
