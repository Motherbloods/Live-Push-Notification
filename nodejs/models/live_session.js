const mongoose = require("mongoose");

const liveSessionSchema = new mongoose.Schema({
  username: { type: String, required: true },
  startTime: { type: Date, required: true },
  duration: { type: Number }, // dalam menit
  date: { type: String }, // format: YYYY-MM-DD
});

const LiveSessions = mongoose.model("LiveSessionsGithub", liveSessionSchema);

module.exports = LiveSessions;
