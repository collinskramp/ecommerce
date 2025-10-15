const mongoose = require('mongoose');

module.exports.dbConnect = async()=>{
    try {
        const dbUrl = process.env.DB_URL || 'mongodb://admin:password@127.0.0.1:27017/ec?authSource=admin';
        console.log('Connecting to MongoDB...');
        await mongoose.connect(dbUrl);
        console.log("Database connected..")
    } catch (error) {
        console.log('Database connection error:', error.message)
    }
}