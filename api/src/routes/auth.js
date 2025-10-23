import express from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/User.js";
import auth from "../middlewares/auth.js";

const router = express.Router();

// register (student)
router.post("/register", async (req, res) => {
  try {
    const { name, studentId, email, password } = req.body;
    if (!name || !studentId || !email || !password)
      return res.status(400).json({ message: "Thiếu thông tin" });

    const existed = await User.findOne({ email });
    if (existed) return res.status(400).json({ message: "Email đã tồn tại" });

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({ name, studentId, email, passwordHash, role: "student" });

    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: "7d" });
    res.json({ token, user: { id: user._id, name, studentId, email, role: user.role } });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const u = await User.findOne({ email });
    if (!u) return res.status(400).json({ message: "Email không tồn tại" });
    const ok = await bcrypt.compare(password, u.passwordHash);
    if (!ok) return res.status(400).json({ message: "Sai mật khẩu" });

    const token = jwt.sign({ id: u._id, role: u.role }, process.env.JWT_SECRET, { expiresIn: "7d" });
    res.json({ token, user: { id: u._id, name: u.name, studentId: u.studentId, email: u.email, role: u.role } });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// profile
router.get("/me", auth, async (req, res) => {
  const u = await User.findById(req.user.id).select("-passwordHash");
  if (!u) return res.status(404).json({ message: "Không tìm thấy user" });
  res.json(u);
});

// my QR data (simple)
router.get("/me/qr", auth, async (req, res) => {
  res.json({ qrData: req.user.id.toString() });
});

export default router;
