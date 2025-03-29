const app = require("./utils/config");
const router = require("./routes/index.routes");
const connectDB = require("./utils/db");
const {
  notFoundHandler,
  errorHandler,
} = require("./middlewares/app.middleware.js");

require("dotenv").config();

connectDB()
  .then(() => {
    const PORT = process.env.PORT;

    app.use(router);
    app.use(notFoundHandler);
    app.use(errorHandler);

    app.listen(PORT, "0.0.0.0", () => {
      console.log(`Server Running on port ${PORT}`);
    });
  })
  .catch((e) => {
    console.log("Failed to connect MongoDB", e);
    process.exit(1);
  });
