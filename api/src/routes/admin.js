import express from "express";
import auth from "../middlewares/auth.js";
import Activity from "../models/Activity.js";
import Registration from "../models/Registration.js";

const router = express.Router();

// admin guard
const isAdmin = (req, res, next) =>
  req.user?.role === "admin" ? next() : res.status(403).json({ message: "Yêu cầu quyền admin" });

// create
router.post("/activities", auth, isAdmin, async (req, res) => {
  const a = await Activity.create({ ...req.body, createdBy: req.user.id, isClosed: false });
  res.status(201).json(a);
});

// update
router.put("/activities/:id", auth, isAdmin, async (req, res) => {
  const a = await Activity.findByIdAndUpdate(req.params.id, req.body, { new: true });
  if (!a) return res.status(404).json({ message: "Không tìm thấy hoạt động" });
  res.json(a);
});

// delete
router.delete("/activities/:id", auth, isAdmin, async (req, res) => {
  const a = await Activity.findByIdAndDelete(req.params.id);
  if (!a) return res.status(404).json({ message: "Không tìm thấy hoạt động" });
  await Registration.deleteMany({ activity: a._id });
  res.json({ message: "Đã xóa hoạt động & đăng ký liên quan" });
});

export default router;
