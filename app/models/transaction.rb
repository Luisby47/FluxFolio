# Transaction model represents buy and sell transactions for investments
# It tracks transaction details including date, type, units, and price
class Transaction < ApplicationRecord
  # Relationships
  belongs_to :investment
  has_many :notes, as: :notable, dependent: :destroy

  # Validations
  validates :transaction_type, presence: true, inclusion: { in: %w[buy sell] }
  validates :transaction_date, presence: true
  validates :units, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }

  # Enum definition for transaction types
  enum :transaction_type, {
    buy: "buy",
    sell: "sell"
  }

  # Calculate the total value of the transaction (units * unit_price)
  def total_value
    units * unit_price
  end

  # Calculate the portfolio's total value at the transaction date
  # Used for historical portfolio value tracking
  def calculate_portfolio_value_at_date
    investment.portfolio.calculate_value_at_date(transaction_date)
  end

  # Calculate the investment's value at the transaction date
  # Used for historical investment value tracking
  def calculate_investment_value_at_date
    investment.calculate_value_at_date(transaction_date)
  end

  # Export transactions to CSV format
  # Used for data export functionality
  def self.to_csv
    require "csv"

    CSV.generate(headers: true) do |csv|
      csv << [ "Date", "Investment", "Type", "Units", "Unit Price", "Total Value", "Notes" ]

      all.includes(:investment, :notes).find_each do |transaction|
        csv << [
          transaction.transaction_date.strftime("%Y-%m-%d"),
          transaction.investment.name,
          transaction.transaction_type.titleize,
          transaction.units,
          transaction.unit_price,
          transaction.total_value,
          transaction.notes.map(&:content).join(" | ")
        ]
      end
    end
  end

  # Export transactions to JSON format
  # Used for data export and API functionality
  def self.to_json_export
    includes(:investment, :notes).map do |transaction|
      {
        date: transaction.transaction_date.strftime("%Y-%m-%d"),
        investment: transaction.investment.name,
        type: transaction.transaction_type,
        units: transaction.units,
        unit_price: transaction.unit_price,
        total_value: transaction.total_value,
        notes: transaction.notes.map { |note| { content: note.content, importance: note.importance } }
      }
    end.to_json
  end

  # Define standard date range options for transaction filtering
  # Used in transaction history filtering UI
  def self.date_range_options
    [
      [ "Last 7 days", 7.days.ago.beginning_of_day ],
      [ "Last 30 days", 30.days.ago.beginning_of_day ],
      [ "Last 90 days", 90.days.ago.beginning_of_day ],
      [ "Last 180 days", 180.days.ago.beginning_of_day ],
      [ "Last 365 days", 365.days.ago.beginning_of_day ],
      [ "All time", 100.years.ago ]
    ]
  end
end
