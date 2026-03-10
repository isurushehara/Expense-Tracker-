const pool = require("../config/db");

exports.getExpenseByCategory = async (req, res) => {

  try {

    const user_id = req.user.id;

    const result = await pool.query(

      `
      SELECT c.name, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = $1 AND t.type = 'expense'
      GROUP BY c.name
      `,

      [user_id]

    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);
  }

};