# Customer Management Backend

Node.js + Express + PostgreSQL backend API for customer management.

## Tech Stack
- Node.js 20
- Express.js 4
- Sequelize ORM
- PostgreSQL

## API Endpoints

POST   /api/customers          - Create customer
GET    /api/customers          - Get all customers
GET    /api/customers/:id      - Get customer by ID
PUT    /api/customers/:id      - Update customer
DELETE /api/customers/:id      - Delete customer
DELETE /api/customers          - Delete all customers

## Environment Variables

See `.env.example` for required environment variables.

## Local Development

npm install
npm run dev

## Docker

docker build -t backend .
docker run -p 8080:8080 backend

## Database Schema

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  firstname VARCHAR(255) NOT NULL,
  lastname VARCHAR(255) NOT NULL,
  age INTEGER,
  address VARCHAR(255),
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
