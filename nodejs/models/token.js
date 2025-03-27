const mongoose = require("mongoose");

const TokenSchemaBigo = new mongoose.Schema({
  token: { type: String, unique: true },
});
