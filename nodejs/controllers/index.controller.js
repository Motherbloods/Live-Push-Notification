const cheerio = require("cheerio");
const axios = require("axios");
require("dotenv").config();

const admin = require("../utils/firebase.js");
const bot = require("../utils/telegram.js");

const LiveStatus = require("../models/live_status.js");
const Token = require("../models/token.js");

const USERNAME_TELEGRAM = process.env.USERNAME_TELEGRAM;
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

const checkLiveStatus = async (userData) => {
  try {
    const $ = cheerio.load(userData);
    const scriptContent = $("#SIGI_STATE").html();
    const isLive = /"isLiveBroadcast"\s*:\s*true/.test(userData);

    if (!scriptContent && !isLive) {
      return { isLive: false, message: "Data tidak ditemukan" };
    }

    const sigIState = JSON.parse(scriptContent);
    const status = sigIState?.LiveRoom?.liveRoomUserInfo?.user?.status;
    let message = "";

    if (status == 2 || isLive) {
      message = `${USERNAME_TIKTOK} sedang live`;
      await bot.sendMessage(USERNAME_TELEGRAM, message);

      const shouldNotify = await updateLiveStatus(USERNAME_TIKTOK, true);
      console.log('ini should',shouldNotify)
      if (shouldNotify) {
        await sendNotification("Live Alert!", "Akun sedang live di TikTok!");
      } else {
        console.log(`${USERNAME_TIKTOK} masih live (notifikasi tidak dikirim)`);
      }
      return { isLive: true, message };
    } else {
      await updateLiveStatus(USERNAME_TIKTOK, false);
      message = `${USERNAME_TIKTOK} tidak sedang live`;
      return { isLive: false, message };
    }
  } catch (e) {
    console.error("Gagal memeriksa live status:", e);
    return { isLive: false, message: "Terjadi kesalahan" };
  }
};

const sendNotification = async (title, body) => {
  try {
    const tokens = await Token.find({});
    const registrationTokens = tokens.map((t) => t.token);

    const message = {
      notification: {
        title: title,
        body: body,
      },
      android: {
        priority: "high",
        notification: {
          priority: "max",
          defaultSound: true,
          visibility: "public",
        },
      },
      data: {
        title: title,
        body: body,
      },
      priority: "high",
      tokens: registrationTokens,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log("Detailed Response:", JSON.stringify(response, null, 2));

    return response;
  } catch (e) {
    console.error("Notification error details:", e.message, e.stack);
    console.error("Error code:", e.code);
    console.error("Error details:", e.details);
    return { error: e.message };
  }
};

const updateLiveStatus = async (userId, isCurrentlyLive) => {
  try {
    const currentTime = new Date();
    let liveStatus = await LiveStatus.findOne({ userId });

    if (!liveStatus) {
      liveStatus = new LiveStatus({
        userId,
        isLive: isCurrentlyLive,
        lastLiveStart: isCurrentlyLive ? currentTime : null,
        lastCheck: currentTime,
      });

      await liveStatus.save();
      return isCurrentlyLive;
    }

    liveStatus.lastCheck = currentTime;

    if (isCurrentlyLive && !liveStatus.isLive) {
      liveStatus.isLive = true;
      liveStatus.lastLiveStart = currentTime;
      await liveStatus.save();
      return true;
    }

    if (isCurrentlyLive && liveStatus.isLive) {
      await liveStatus.save();
      return false;
    }

    if (!isCurrentlyLive) {
      liveStatus.isLive = false;
      liveStatus.lastLiveStart = null;
      await liveStatus.save();
    }

    return false;
  } catch (e) {
    console.error("Error updating live status:", e);
    return false;
  }
};

module.exports = { getDataURL, storeFCMToken };
