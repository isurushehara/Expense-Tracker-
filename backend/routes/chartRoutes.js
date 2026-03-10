const express = require("express");
const router = express.Router();

const chartController = require("../controllers/chartController");
const authMiddleware = require("../middleware/authMiddleware");

router.get("/expense-category", authMiddleware, chartController.getExpenseByCategory);

module.exports = router;