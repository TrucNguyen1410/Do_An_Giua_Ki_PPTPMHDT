import express from "express";
import auth from "../middlewares/auth.js";
import Activity from "../models/Activity.js";
import Registration from "../models/Registration.js";

const router = express.Router();

// ========================
// 🔹 LẤY DANH SÁCH HOẠT ĐỘNG
// ========================
router.get("/", auth, async (req, res) => {
  try {
    const now = new Date();
    const { open } = req.query;
    const filter = {};

    if (open === "true") {
      filter.$and = [{ isClosed: false }, { deadline: { $gte: now } }];
    }

    const list = await Activity.find(filter).sort({ startTime: 1 });
    const ids = list.map((a) => a._id);
    const regs = await Registration.find({
      user: req.user.id,
      activity: { $in: ids },
    });
    const regSet = new Set(regs.map((r) => r.activity.toString()));
    const data = list.map((a) => ({
      ...a.toObject(),
      isRegistered: regSet.has(a._id.toString()),
    }));

    res.json(data);
  } catch (e) {
    console.error("❌ Lỗi lấy danh sách:", e);
    res.status(500).json({ message: e.message });
  }
});

// ========================
// 🔹 SINH VIÊN ĐĂNG KÝ
// ========================
router.post("/:id/register", auth, async (req, res) => {
  try {
    const a = await Activity.findById(req.params.id);
    if (!a) return res.status(404).json({ message: "Không tìm thấy hoạt động" });

    const now = new Date();
    if (a.isClosed || a.deadline < now)
      return res.status(400).json({ message: "Form đã đóng" });

    const count = await Registration.countDocuments({ activity: a._id });
    if (count >= a.capacity) {
      a.isClosed = true;
      await a.save();
      return res.status(400).json({ message: "Đã đủ số lượng, form đã đóng" });
    }

    const existed = await Registration.findOne({
      user: req.user.id,
      activity: a._id,
    });
    if (existed)
      return res.status(400).json({ message: "Bạn đã đăng ký hoạt động này" });

    await Registration.create({ user: req.user.id, activity: a._id });
    res.json({ message: "Đăng ký thành công" });
  } catch (e) {
    console.error("❌ Lỗi đăng ký:", e);
    res.status(500).json({ message: e.message });
  }
});

// ========================
// 🔹 SINH VIÊN HỦY ĐĂNG KÝ
// ========================
router.post("/:id/unregister", auth, async (req, res) => {
  try {
    const a = await Activity.findById(req.params.id);
    if (!a) return res.status(404).json({ message: "Không tìm thấy hoạt động" });

    const reg = await Registration.findOne({
      user: req.user.id,
      activity: a._id,
    });
    if (!reg)
      return res.status(400).json({ message: "Bạn chưa đăng ký hoạt động này" });

    await reg.deleteOne();

    const count = await Registration.countDocuments({ activity: a._id });
    const now = new Date();
    if (count < a.capacity && a.deadline > now && a.isClosed) {
      a.isClosed = false;
      await a.save();
    }

    res.json({ message: "Đã hủy đăng ký" });
  } catch (e) {
    console.error("❌ Lỗi hủy đăng ký:", e);
    res.status(500).json({ message: e.message });
  }
});

// ========================
// 🔹 XEM LỊCH SỬ ĐĂNG KÝ
// ========================
router.get("/me/registrations", auth, async (req, res) => {
  try {
    const regs = await Registration.find({ user: req.user.id })
      .sort({ createdAt: -1 })
      .populate("activity");
    res.json(regs);
  } catch (e) {
    console.error("❌ Lỗi lấy lịch sử đăng ký:", e);
    res.status(500).json({ message: e.message });
  }
});

// ========================
// 🔹 ADMIN: XÓA HOẠT ĐỘNG
// ========================
router.delete("/:id", auth, async (req, res) => {
  try {
    const activity = await Activity.findById(req.params.id);
    if (!activity)
      return res.status(404).json({ message: "Không tìm thấy hoạt động" });

    // Xóa luôn các bản ghi đăng ký liên quan
    await Registration.deleteMany({ activity: activity._id });
    await activity.deleteOne();

    res.json({ message: "Đã xóa hoạt động" });
  } catch (e) {
    console.error("❌ Lỗi khi xóa hoạt động:", e);
    res.status(500).json({ message: "Không thể xóa hoạt động" });
  }
});

export default router;
