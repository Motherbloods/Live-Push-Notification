const notFoundHandler = (req, res, next) => {
  res.status(404).json({
    succes: false,
    message: "Route not found",
  });
};

const errorHandler = (err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: "Internal Server Error",
  });
};

module.exports = { notFoundHandler, errorHandler };
