# SwiftPick
SwiftPick is a modern eCommerce web application built with Ruby on Rails. It enables users to browse and search products, manage carts, and complete secure payments using Stripe. The platform includes an admin panel for managing products, categories, orders, and users. RSpec is used for testing to ensure reliability.

## Ruby Version

This project is built with:

- Ruby 3.2.3  
- Rails 8.1.1
- SQLite3

## Clone the repository

```bash
git clone git@github.com:Raees-Haider/swiftPick.git
```

```bash
cd swiftPick
```

## Install Dependencies

```bash
bundle install
```

## Database Setup

Run migrations:
```bash
rails db:migrate
```

```bash
rails db:seed
```

## Stripe Setup

After cloning the project, create a `.env` file in the root directory and add your Stripe keys:

```bash
STRIPE_SECRET_KEY=sk_test_............
STRIPE_PUBLISHABLE_KEY=pk_test_............
```







## Starting the Application Locally

To startup the Rails server, make sure that you are in the root of the application in the terminal and run:
```bash
rails server
```

This will startup the rails server and you will see output such as the following:
```bash
=> Booting Puma
=> Rails 8.1.1 application starting in development 
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Puma version: 7.1.0 ("Neon Witch")
* Ruby version: ruby 3.2.3 (2024-01-18 revision 52bb2ac0a6) [x86_64-linux-gnu]
*  Min threads: 3
*  Max threads: 3
*  Environment: development
*          PID: 24017
* Listening on http://127.0.0.1:3000
* Listening on http://[::1]:3000
Use Ctrl-C to stop
```

Now that the server is running properly, you can go and verify that it's working properly in the browser by going to: http://localhost:3000/

## Admin Login Credentials

Email: 
```bash
admin@example.com
```

Password: 
```bash
password123
```


## Running the Test Suite

This project uses RSpec for testing. To run the test suite:

```bash
bundle exec rspec
```

You can also run individual spec files:
```bash
bundle exec rspec spec/models/user_spec.rb
```

