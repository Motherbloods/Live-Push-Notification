const TelegramBot = require("node-telegram-bot-api");
require("dotenv").config();

const bot = new TelegramBot(process.env.TOKEN, { polling: true });

bot.onText(/\/start/, (msg) => {
  const chatId = msg.chat.id;
  const username = msg.from.username;

  // Simpan chatId ini ke database sesuai akun mereka
  console.log(`User ${username} chat ID: ${chatId}`);

  bot.sendMessage(chatId, "Bot berhasil dihubungkan!");
});

module.exports = bot;
