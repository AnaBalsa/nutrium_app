# README

# Nutrium Appointment Requests App

This project is a web that implements a simplified appointment-request flow between guests and nutrition professionals (nutritionists).It's build with:

- Ruby on Rails (version 7.2.3)
- PostgreSQL
- React (nutritionist dashboard)
- esbuild (`jsbundling-rails`)
- Hotwire (Turbo + Stimulus)
- Email preview in development via `letter_opener_web`
- Minitest (testing)

## Quick Start 
First clone the repo
```bash
bundle install
npm install
rails db:create db:migrate db:seed
npm run build
rails s
```
Then open: http://localhost:3000

## Setup instructions
### Requirements
Make sure the following are installed:
- Ruby 3.3.x
- Node.js (>=18)
- PostgreSQL
- npm

1. Clone the repo
```bash
git clone https://github.com/AnaBalsa/nutrium_app.git
cd nutrium_app
```

2. Install dependencies
```bash
bundle install
```

3. Setup the database
Create and migrate the database:
```bash
rails db:create
rails db:migrate
```

Seed the database with sample nutritionists and services:
```bash
rails db:seed
```

4. Build JS assets
Compile JavaScript (React + Stimulus):
```bash
npm run build
```

5. Run the application
Start the Rails server:
```bash
rails s
```

Open: http://localhost:3000

## How to use (quick demo)

### Guest flow
1. Open `http://localhost:3000/`
2. Search nutritionists/services
3. Click **Schedule appointment**
4. Fill guest name/email + date/time and submit
5. The request is created as `pending`

### Nutritionist flow
1. Open `http://localhost:3000/nutritionists`
2. Pick a nutritionist and open **Pending Requests**
3. Accept or reject pending requests
4. When accepting a request, other overlapping pending requests for the professional are automatically rejected
5. Guests are notified by email (see email here: `http://localhost:3000/letter_opener`)

## Architecture / Design decisions
- **Service Objects for Business Logic** – Core domain rules are implemented in `AppointmentRequests::Create` and `AppointmentRequests::Decide`, keeping controllers thin and making the logic easier to test.

- **Hybrid Rails + React Architecture** – Rails views with Turbo/Stimulus power the guest flow, while React is used for the nutritionist dashboard where more dynamic UI updates are required.

- **JSON API for the Nutritionist Dashboard** – The React dashboard communicates with the Rails backend through JSON endpoints under `/api`, allowing request updates without page reloads while keeping backend logic independent from the frontend.

- **Lightweight JavaScript Tooling** – The project uses `jsbundling-rails` with esbuild to bundle React, Turbo and Stimulus into a single asset, avoiding the complexity of heavier bundlers.

## Testing Strategy
The test suite focuses on validating core domain logic and API behavior.

### Service Object Tests

Service-level tests validate the main business rules:

`AppointmentRequests::Create`
- Rejects previous pending requests for the same guest email
- Creates a new pending request
- Normalizes guest email

`AppointmentRequests::Decide`
- Accepting a request automatically rejects overlapping pending requests

### API Integration Tests

Integration tests cover endpoints used by the Nutritionists React dashboard:

`PATCH /api/appointment_requests/:id/decide`
- Returns HTTP 200
- Updates request status

`GET /api/nutritionists/:nutritionist_id/appointment_requests`
- Returns only pending requests
