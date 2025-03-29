const mongoose = require("mongoose");

const liveStatusSchema = new mongoose.Schema({
  userId: { type: String, unique: true },
  isLive: { type: Boolean, default: false },
  lastLiveStart: { type: Date },
  lastCheck: { type: Date },
});

const LiveStatus = mongoose.model("LiveStatusTiktokGithub", liveStatusSchema);

module.exports = LiveStatus;
