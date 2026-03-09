const pool = require("../config/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const JWT_SECRET = "mysecretkey";

/* Register User */
exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const userExists = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (userExists.rows.length > 0) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      "INSERT INTO users (name, email, password) VALUES ($1,$2,$3) RETURNING *",
      [name, email, hashedPassword]
    );

    res.json({
      message: "User registered successfully",
      user: result.rows[0],
    });
  } catch (err) {
    console.error(err);
  }
};

/* Login User */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const result = await pool.query(
      "SELECT * FROM users WHERE email=$1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ message: "User not found" });
    }

    const user = result.rows[0];

    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return res.status(400).json({ message: "Invalid password" });
    }

    const token = jwt.sign({ id: user.id }, JWT_SECRET, {
      expiresIn: "24h",
    });

    res.json({
      message: "Login successful",
      token: token,
    });
  } catch (err) {
    console.error(err);
  }
};