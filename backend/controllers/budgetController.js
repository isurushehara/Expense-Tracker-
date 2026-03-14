const pool = require("../config/db");

exports.setBudget = async (req, res) => {

  try {

    const user_id = req.user.id;
    const { category_id, limit_amount } = req.body;

    const result = await pool.query(

      `INSERT INTO budgets (user_id, category_id, limit_amount)
       VALUES ($1,$2,$3)
       RETURNING *`,

      [user_id, category_id, limit_amount]

    );

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);
  }

};

exports.getBudgets = async (req, res) => {

  try {

    const user_id = req.user.id;

    const result = await pool.query(

      `
      SELECT
      b.id,
      c.name,
      b.limit_amount,
      COALESCE(SUM(t.amount),0) AS spent

      FROM budgets b
      JOIN categories c ON b.category_id = c.id

      LEFT JOIN transactions t
      ON t.category_id = c.id
      AND t.user_id = $1
      AND t.type = 'expense'

      WHERE b.user_id = $1

      GROUP BY b.id, c.name
      `,

      [user_id]

    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);
  }

};