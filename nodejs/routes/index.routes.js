const express = require("express");
const router = express.Router();
const {
  getDataURL,
  storeFCMToken,
} = require("../controllers/index.controller");

router.get("/live", getDataURL);
router.post("/fcm", storeFCMToken);

module.exports = router;
