const mongoose = require('mongoose');

module.exports.dbConnect = async()=>{
    try {
        await mongoose.connect('mongodb://127.0.0.1:27017/ec',{useNewURLParser: true})
        console.log("Database connected..")
    } catch (error) {
        console.log(error.message)
    }
}