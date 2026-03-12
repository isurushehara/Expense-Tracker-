const pool = require("../config/db");

/* Add Transaction */
exports.addTransaction = async (req, res) => {
  try {
    const { category_id, amount, type, description, date } = req.body;
    const user_id = req.user.id;

    const result = await pool.query(
      `INSERT INTO transactions 
      (user_id, category_id, amount, type, description, date) 
      VALUES ($1,$2,$3,$4,$5,$6) 
      RETURNING *`,
      [user_id, category_id, amount, type, description, date]
    );

    res.json({
      message: "Transaction added",
      transaction: result.rows[0],
    });
  } catch (err) {
    console.error(err);
  }
};

/* Get Transactions */
exports.getTransactions = async (req, res) => {
  try {
    const user_id = req.user.id;

    const result = await pool.query(
      "SELECT * FROM transactions WHERE user_id=$1 ORDER BY date DESC",
      [user_id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
  }
};

/* Delete Transaction */
exports.deleteTransaction = async (req, res) => {
  try {
    const id = req.params.id;

    await pool.query("DELETE FROM transactions WHERE id=$1", [id]);

    res.json({ message: "Transaction deleted" });
  } catch (err) {
    console.error(err);
  }
};

exports.updateTransaction = async (req, res) => {

  try {

    const id = req.params.id;

    const { category_id, amount, type, description, date } = req.body;

    const result = await pool.query(

      `UPDATE transactions
       SET category_id=$1, amount=$2, type=$3, description=$4, date=$5
       WHERE id=$6
       RETURNING *`,

      [category_id, amount, type, description, date, id]

    );

    res.json({
      message: "Transaction updated",
      transaction: result.rows[0]
    });

  } catch (err) {
    console.error(err);
  }

};