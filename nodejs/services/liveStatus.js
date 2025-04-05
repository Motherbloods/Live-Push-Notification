const admin = require("../utils/firebase.js");
const bot = require("../utils/telegram.js");
const cheerio = require("cheerio");
const LiveStatus = require("../models/live_status.js");
const LiveSession = require("../models/live_session.js");
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
    const formattedDate = currentTime.toISOString().split("T")[0]; // YYYY-MM-DD format
    let shouldNotify = false;

    // Jika tidak ada status live yang tersimpan sebelumnya
    if (!liveStatus) {
      // Membuat record LiveStatus baru
      liveStatus = new LiveStatus({
        userId,
        isLive: isCurrentlyLive,
        lastLiveStart: isCurrentlyLive ? currentTime : null,
        lastCheck: currentTime,
      });

      await liveStatus.save();

      // Jika sedang live, buat sesi baru
      if (isCurrentlyLive) {
        await createNewLiveSession(userId, currentTime, formattedDate);
        shouldNotify = true;
      }

      return shouldNotify;
    }

    // Update waktu pemeriksaan terakhir
    liveStatus.lastCheck = currentTime;

    // Kondisi 1: Status berubah dari tidak live menjadi live
    if (isCurrentlyLive && !liveStatus.isLive) {
      liveStatus.isLive = true;
      liveStatus.lastLiveStart = currentTime;
      await liveStatus.save();

      // Membuat catatan LiveSession baru setiap kali pengguna memulai live
      await createNewLiveSession(userId, currentTime, formattedDate);
      shouldNotify = true;
    }
    // Kondisi 2: Masih live (tidak ada perubahan status)
    else if (isCurrentlyLive && liveStatus.isLive) {
      await liveStatus.save();
      shouldNotify = false;
    }
    // Kondisi 3: Status berubah dari live menjadi tidak live
    else if (!isCurrentlyLive && liveStatus.isLive) {
      liveStatus.isLive = false;
      await liveStatus.save();

      // Menyelesaikan sesi live yang sedang berlangsung
      await completeLiveSession(userId, currentTime);
      shouldNotify = false;
    }
    // Kondisi 4: Tetap tidak live (tidak ada perubahan status)
    else {
      await liveStatus.save();
      shouldNotify = false;
    }

    return shouldNotify;
  } catch (e) {
    console.error("Error updating live status:", e);
    return false;
  }
};

// Fungsi untuk membuat sesi live baru
const createNewLiveSession = async (username, startTime, formattedDate) => {
  try {
    const newSession = new LiveSession({
      username: username,
      startTime: startTime,
      date: formattedDate,
    });

    await newSession.save();
    console.log(
      `New live session created for ${username} at ${startTime.toISOString()}`
    );
    return newSession;
  } catch (e) {
    console.error("Error creating live session:", e);
    return null;
  }
};

// Fungsi untuk menyelesaikan sesi live yang sedang berlangsung
const completeLiveSession = async (username, endTime) => {
  try {
    // Cari sesi live terbaru yang belum memiliki waktu berakhir
    const ongoingSession = await LiveSession.findOne({
      username: username,
      endTime: { $exists: false },
    }).sort({ startTime: -1 });

    if (ongoingSession) {
      // Hitung durasi dalam menit
      const durationMinutes = Math.round(
        (endTime - ongoingSession.startTime) / (1000 * 60)
      );

      // Update sesi dengan waktu berakhir dan durasi
      ongoingSession.endTime = endTime;
      ongoingSession.duration = durationMinutes;

      await ongoingSession.save();
      console.log(
        `Live session ended for ${username}. Duration: ${durationMinutes} minutes`
      );
      return ongoingSession;
    } else {
      console.log(`No ongoing live session found for ${username}`);
      return null;
    }
  } catch (e) {
    console.error("Error completing live session:", e);
    return null;
  }
};

module.exports = { checkLiveStatus };
