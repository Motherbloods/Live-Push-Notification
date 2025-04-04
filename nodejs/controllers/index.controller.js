const axios = require("axios");
const Token = require("../models/token.js");
const LiveSessions = require("../models/live_session.js");
const { checkLiveStatus } = require("../services/liveStatus.js");
require("dotenv").config();

const USERNAME_TIKTOK = process.env.USERNAME_TIKTOK;

const getDataURL = async (req, res) => {
  const URL = process.env.URLTARGET;
  try {
    const response = await axios.get(`${URL}/${USERNAME_TIKTOK}/live`, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
      },
    });

    const result = await checkLiveStatus(response.data);
    return res.status(200).json({ status: "success", ...result });
  } catch (e) {
    console.error("Terjadi kesalahan:", e);
    return res.status(500).json({ message: "Terjadi kesalahan" });
  }
};
const storeFCMToken = async (req, res) => {
  try {
    const { token } = req.body;
    if (!token) {
      return res.status(400).json({ message: "Token tidak boleh kosong" });
    }
    try {
    } catch (e) {
      const existingToken = Token.findOne({ token });
      if (!existingToken) {
        const newToken = await Token.create({ token });
        console.log("Token baru disimpan:", newToken.token);
      } else {
        console.log("Token sudah ada");
      }
      return res.status(200).json({ message: "Token FCM disimpan" });
    }
  } catch (e) {
    console.error("Gagal menyimpan token:", e);
    return res.status(500).json({ message: "Server error" });
  }
};
const getDataDB = async (req, res) => {
  try {
    const sessions = await LiveSessions.find().sort({ startTime: -1 });
    res.json(sessions);
  } catch (e) {
    console.log(e.message);
  }
};
module.exports = { getDataURL, storeFCMToken, getDataDB };
