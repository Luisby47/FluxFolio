
# Reset database before seeding
puts "Clearing existing data..."
[Transaction, Investment, Note, NoteDraft, Session, Portfolio, User].each do |model|
  puts "Clearing #{model.name} records..."
  model.destroy_all
end

# Create Users
puts "Creating users..."
users = [
  { email: "test1@example.com", password: "Password123!" },
  { email: "test@example.com", password: "Password123!" },
  { email: "test2@example.com", password: "Password123!" },
  { email: "admin@fluxfolio.com", password: "Admin123!" }
]

created_users = users.map do |user_attrs|
  User.create!(
    email_address: user_attrs[:email],
    password: user_attrs[:password],
    password_confirmation: user_attrs[:password]
  )
end

# Create Portfolios
puts "Creating portfolios..."
portfolios = [
  { name: "Retirement" },
  { name: "Growth" },
  { name: "Income" },
  { name: "Tech Stocks" },
  { name: "Real Estate" }
]

created_portfolios = []

created_users.each do |user|
  # Each user gets 2-3 portfolios
  user_portfolios = portfolios.sample(rand(2..3))
  
  user_portfolios.each do |portfolio|
    created_portfolios << Portfolio.create!(
      name: portfolio[:name],
      user: user
    )
  end
end

# Create Investments
puts "Creating investments..."
investment_data = [
  { name: "Apple Inc.", symbol: "AAPL", investment_type: :stock, current_unit_price: 182.52 },
  { name: "Microsoft", symbol: "MSFT", investment_type: :stock, current_unit_price: 420.21 },
  { name: "Amazon", symbol: "AMZN", investment_type: :stock, current_unit_price: 182.41 },
  { name: "Vanguard S&P 500 ETF", symbol: "VOO", investment_type: :etf, current_unit_price: 470.10 },
  { name: "iShares Core U.S. Aggregate Bond ETF", symbol: "AGG", investment_type: :bond, current_unit_price: 98.71 },
  { name: "Fidelity 500 Index Fund", symbol: "FXAIX", investment_type: :mutual_fund, current_unit_price: 173.40 },
  { name: "Tesla", symbol: "TSLA", investment_type: :stock, current_unit_price: 173.60 },
  { name: "Bitcoin", symbol: "BTC", investment_type: :cryptocurrency, current_unit_price: 62345.78 },
  { name: "Ethereum", symbol: "ETH", investment_type: :cryptocurrency, current_unit_price: 3451.23 },
  { name: "Rental Property", symbol: nil, investment_type: :real_estate, current_unit_price: 350000.00 },
  { name: "Startup Investment", symbol: nil, investment_type: :private_equity, current_unit_price: 50000.00 }
]

created_investments = []

created_portfolios.each do |portfolio|
  # Each portfolio gets 3-6 investments
  portfolio_investments = investment_data.sample(rand(3..6))
  
  portfolio_investments.each do |investment|
    created_investments << Investment.create!(
      name: investment[:name],
      symbol: investment[:symbol],
      investment_type: investment[:investment_type],
      current_unit_price: investment[:current_unit_price],
      status: :active,
      portfolio: portfolio
    )
  end
end

# Create Transactions
puts "Creating transactions..."
created_investments.each do |investment|
  # Initial buy transaction (between 1 year and 3 months ago)
  initial_date = rand(90..365).days.ago
  initial_units = rand(1..100)
  initial_price = investment.current_unit_price * (0.7 + rand * 0.6) # 70-130% of current price
  
  Transaction.create!(
    investment: investment,
    transaction_type: :buy,
    transaction_date: initial_date,
    units: initial_units,
    unit_price: initial_price
  )
  
  # Add 1-5 more transactions per investment
  rand(1..5).times do |i|
    transaction_date = rand(1..89).days.ago
    transaction_type = [:buy, :buy, :buy, :sell].sample # More buys than sells
    units = rand(1..50)
    price_change = 0.8 + rand * 0.4 # 80-120% price variation
    unit_price = initial_price * price_change
    
    Transaction.create!(
      investment: investment,
      transaction_type: transaction_type,
      transaction_date: transaction_date,
      units: units,
      unit_price: unit_price
    )
  end
  
  # Update investment with current price (date after all transactions)
  investment.update!(
    current_unit_price: investment.current_unit_price,
    updated_at: Time.current
  )
  
  # Add some standalone notes
  rand(0..2).times do
    Note.create!(
      notable: investment,
      content: [
        "Watching this investment closely",
        "Consider increasing position",
        "Research upcoming news",
        "Check quarterly earnings report",
        "Monitor market conditions affecting this investment"
      ].sample,
      importance: rand(1..5)
    )
  end
end

# Add some portfolio notes
created_portfolios.each do |portfolio|
  rand(1..3).times do
    Note.create!(
      notable: portfolio,
      content: [
        "Portfolio rebalancing due on #{(Date.today + rand(1..60).days).strftime('%b %d, %Y')}",
        "Consider adding exposure to #{['tech', 'healthcare', 'energy', 'financials'].sample} sector",
        "Review overall allocation quarterly",
        "Target annual return: #{rand(5..15)}%",
        "Long-term investment horizon: #{rand(10..30)} years"
      ].sample,
      importance: rand(1..5)
    )
  end
  
  # Create a note draft
  if rand > 0.7
    NoteDraft.create!(
      notable: portfolio,
      user: portfolio.user,
      content: "Draft note: #{['Considering new investment strategies', 'Research tax implications', 'Plan for next contribution'].sample}",
      importance: rand(1..5),
      last_autosaved_at: Time.current
    )
  end
end

puts "Seed completed successfully!"
puts "Created #{User.count} users"
puts "Created #{Portfolio.count} portfolios"
puts "Created #{Investment.count} investments"
puts "Created #{Transaction.count} transactions"
puts "Created #{Note.count} notes"
