// Simple populate script without authentication issues
// This uses the same connection as the backend

const mongoose = require('mongoose');
require('dotenv').config({ path: './backend/.env' });

// Use the DB_URL from backend .env or fallback
const DB_URL = process.env.DB_URL || 'mongodb://127.0.0.1:27017/ec';

console.log(`Connecting to: ${DB_URL}`);

// Run populate.js script
const populateScript = require('./populate');
