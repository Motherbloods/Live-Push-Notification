const admin = require("../utils/firebase.js");
const bot = require("../utils/telegram.js");
const cheerio = require("cheerio");
const LiveStatus = require("../models/live_status.js");
const Token = require("../models/token.js");

const USERNAME_TELEGRAM = process.env.USERNAME_TELEGRAM;
const USERNAME_TIKTOK = process.env.USERNAME_TIKTOK;

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
      console.log("ini should", shouldNotify);
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

module.exports = { checkLiveStatus };
