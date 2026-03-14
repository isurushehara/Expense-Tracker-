const pool = require("../config/db");

exports.getDashboard = async (req, res) => {
  try {
    const user_id = req.user.id;

    const incomeResult = await pool.query(
      "SELECT COALESCE(SUM(amount),0) AS total_income FROM transactions WHERE user_id=$1 AND type='income'",
      [user_id]
    );

    const expenseResult = await pool.query(
      "SELECT COALESCE(SUM(amount),0) AS total_expense FROM transactions WHERE user_id=$1 AND type='expense'",
      [user_id]
    );

    const total_income = incomeResult.rows[0].total_income;
    const total_expense = expenseResult.rows[0].total_expense;

    const balance = total_income - total_expense;

    res.json({
      total_income,
      total_expense,
      balance
    });

  } catch (err) {
    console.error(err);
  }
};