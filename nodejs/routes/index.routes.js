const express = require("express");
const router = express.Router();
const {
  getDataURL,
  storeFCMToken,
  getDataDB,
} = require("../controllers/index.controller");

router.get("/livesessions", getDataDB);
router.get("/live", getDataURL);
router.post("/fcm", storeFCMToken);

module.exports = router;
