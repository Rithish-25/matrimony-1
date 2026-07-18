const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const connectDB = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const profileRoutes = require('./routes/profileRoutes');
const adminRoutes = require('./routes/adminRoutes');

// Connect to Database
connectDB();

const app = express();

// Core Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve Local Image Uploads as Static Assets
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routing API Handlers
app.use('/api/auth', authRoutes);
app.use('/api/profiles', profileRoutes);
app.use('/api/admin', adminRoutes);

// Root Service Diagnostics
app.get('/', (req, res) => {
  res.status(200).json({ success: true, message: 'Welcome to Soulmate Matrimony API Server' });
});

// Global Server Error Logging
app.use((err, req, res, next) => {
  console.error('Server error:', err.stack);
  res.status(500).json({ success: false, message: 'Something went wrong on the server!' });
});

// Bind Server Listener
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
