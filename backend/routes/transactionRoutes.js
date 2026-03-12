const express = require("express");
const router = express.Router();

const transactionController = require("../controllers/transactionController");
const authMiddleware = require("../middleware/authMiddleware");

router.post("/", authMiddleware, transactionController.addTransaction);

router.get("/", authMiddleware, transactionController.getTransactions);

router.delete("/:id", authMiddleware, transactionController.deleteTransaction);

router.put("/:id", authMiddleware, transactionController.updateTransaction);

module.exports = router;