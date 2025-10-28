const express = require('express');
const cors = require('cors');
const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database
const db = require('./app/models');
db.sequelize.sync();

// Routes
require('./app/routes/customer.routes')(app);

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'Customer Management API' });
});

// Start server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
