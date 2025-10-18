import express from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/User.js";

const router = express.Router();
const DOMAIN = process.env.ALLOWED_EMAIL_DOMAIN;

router.post("/register", async (req, res) => {
  try {
    const { name, studentId, email, password } = req.body;
    if (!email?.toLowerCase().endsWith(`@${DOMAIN}`)) {
      return res.status(400).json({ message: `Email phải có đuôi @${DOMAIN}` });
    }
    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists) return res.status(409).json({ message: "Email đã tồn tại" });

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({ name, studentId, email: email.toLowerCase(), passwordHash, role: "student" });

    const token = jwt.sign({ id: user._id, role: user.role, name: user.name }, process.env.JWT_SECRET, { expiresIn: "7d" });
    res.json({ token, user: { id: user._id, name: user.name, email: user.email, role: user.role, studentId: user.studentId } });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) return res.status(400).json({ message: "Sai email hoặc mật khẩu" });
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(400).json({ message: "Sai email hoặc mật khẩu" });
    const token = jwt.sign({ id: user._id, role: user.role, name: user.name }, process.env.JWT_SECRET, { expiresIn: "7d" });
    res.json({ token, user: { id: user._id, name: user.name, email: user.email, role: user.role, studentId: user.studentId } });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

router.get("/me", async (req, res) => {
  res.json({ ok: true });
});

export default router;
