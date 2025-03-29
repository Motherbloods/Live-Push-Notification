const mongoose = require("mongoose");
require("dotenv").config();

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("MongoDB Connected Successfully");
  } catch (e) {
    console.error("MongoDB Connection Error: ", e);
    process.exit(1);
  }
};

module.exports = connectDB;
