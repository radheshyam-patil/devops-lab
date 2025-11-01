const express = require('express');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint (for Docker health checks)
app.get('/', (req, res) => {
  res.json({ message: 'Customer Management API', status: 'ok' });
});

// Database setup with retry logic
const db = require('./app/models');

let dbConnected = false;
let retries = 0;
const maxRetries = 10;

function connectDB() {
  retries++;
  console.log(`[${retries}/${maxRetries}] Attempting database connection...`);
  
  db.sequelize.authenticate()
    .then(() => {
      console.log('✓ Database authenticated');
      return db.sequelize.sync({ force: false });
    })
    .then(() => {
      console.log('✓ Database synced');
      dbConnected = true;
    })
    .catch(err => {
      console.error(`✗ Database error: ${err.message}`);
      if (retries < maxRetries) {
        const delay = Math.min(5000 * retries, 30000);
        console.log(`Retrying in ${delay}ms...`);
        setTimeout(connectDB, delay);
      } else {
        console.error('Max retries reached. Exiting.');
        process.exit(1);
      }
    });
}

// Start connecting to database
connectDB();

// Routes (only after successful connection)
setTimeout(() => {
  require('./app/routes/customer.routes')(app);
  console.log('✓ Routes registered');
}, 1000);

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ message: 'Internal Server Error' });
});

// Start server
const PORT = process.env.PORT || 8080;
const server = app.listen(PORT, () => {
  console.log(`✓ Server listening on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
