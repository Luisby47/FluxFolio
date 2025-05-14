# Floxfolio

![Floxfolio](public/icon.svg)

A modern, full-featured investment portfolio tracking application built with Ruby on Rails 8.

## Overview

Floxfolio allows users to create and manage investment portfolios containing various types of assets. Track stocks, cryptocurrencies, ETFs, real estate, art, and more in one unified platform. The application enables detailed transaction tracking (buys/sells), note-taking, and portfolio performance analytics.

## Features

- **Multiple Portfolio Management**: Create and manage multiple investment portfolios
- **Diverse Asset Types**: Track any type of investment (stocks, crypto, ETFs, art, etc.)
- **Transaction Tracking**: Record buy/sell transactions with full history
- **Notes System**: Add and manage notes for portfolios and individual investments
- **Responsive Design**: Built with Tailwind CSS for a modern, mobile-first experience

## Technology Stack

- <a href="https://rubyonrails.org/" target="_blank"><img src="https://img.shields.io/badge/Rails-8.0.2-CC0000?logo=ruby-on-rails&logoColor=white" alt="Rails 8.0.2"></a> - Web application framework
- <a href="https://www.ruby-lang.org/" target="_blank"><img src="https://img.shields.io/badge/Ruby-3.3.8-CC342D?logo=ruby&logoColor=white" alt="Ruby 3.3.4"></a> - Programming language
- <a href="https://www.sqlite.org/" target="_blank"><img src="https://img.shields.io/badge/SQLite-003B57?logo=sqlite&logoColor=white" alt="SQLite"></a> - Database engine
- <a href="https://tailwindcss.com/" target="_blank"><img src="https://img.shields.io/badge/Tailwind_CSS-4.2-38B2AC?logo=tailwind-css&logoColor=white" alt="Tailwind CSS"></a> - Utility-first CSS framework
- <a href="https://hotwired.dev/" target="_blank"><img src="https://img.shields.io/badge/Hotwire-Turbo_|_Stimulus-FFB0EA?logo=hotwired&logoColor=white" alt="Hotwire"></a> - Modern, HTML-over-the-wire approach
- <a href="https://github.com/rails/importmap-rails" target="_blank"><img src="https://img.shields.io/badge/Import_Maps-2338B2?logo=ruby&logoColor=white" alt="Import Maps"></a> - Use JavaScript modules without transpiling
- <a href="https://github.com/bcrypt-ruby/bcrypt-ruby" target="_blank"><img src="https://img.shields.io/badge/BCrypt-Authentication-00758F?logo=rubygems&logoColor=white" alt="BCrypt"></a> - Secure password hashing
- <a href="https://kamal-deploy.org/" target="_blank"><img src="https://img.shields.io/badge/Kamal-Deployment-FF9900?logo=docker&logoColor=white" alt="Kamal"></a> - Docker-based deployment solution



## Setup

### Prerequisites

- Ruby 3.3.4
- Node.js and Yarn (for JavaScript dependencies)
- SQLite3 (for development)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/floxfolio.git
cd floxfolio
```

2. Install Ruby dependencies:

```bash
bundle install
```

3. Set up the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

4. Start the development server:

```bash
bin/dev
```

5. Visit http://localhost:3000 in your browser

## Development

### Running Tests

```bash
bin/rails test
```

### Code Quality

This project uses RuboCop with Rails Omakase style guide:

```bash
bundle exec rubocop
```

### Docker

Build and run with Docker:

```bash
docker build -t floxfolio .
docker run -p 3000:3000 floxfolio
```

## Deployment

This application is configured for deployment using Kamal:

```bash
bundle exec kamal setup
bundle exec kamal deploy
```

## License

This project is licensed under the terms of the LICENSE file included in the repository.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
