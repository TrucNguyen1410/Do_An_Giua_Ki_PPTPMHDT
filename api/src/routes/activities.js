import express from "express";
import { auth } from "../middlewares/auth.js";
import Activity from "../models/Activity.js";
import Registration from "../models/Registration.js";

const router = express.Router();

/* =======================================================
   🧩 1️⃣ LẤY DANH SÁCH HOẠT ĐỘNG (CẢ ADMIN & SV)
   ======================================================= */
router.get("/", auth(), async (req, res) => {
  try {
    const now = new Date();
    const { open } = req.query;

    const filter = {};
    if (open === "true") {
      filter.$and = [{ isClosed: false }, { deadline: { $gte: now } }];
    }

    const list = await Activity.find(filter).sort({ startTime: 1 });
    res.json(list);
  } catch (e) {
    console.error("❌ Lỗi lấy danh sách hoạt động:", e);
    res.status(500).json({ message: e.message });
  }
});

/* =======================================================
   🧩 2️⃣ ADMIN TẠO MỚI HOẠT ĐỘNG
   ======================================================= */
router.post("/", auth(["admin"]), async (req, res) => {
  try {
    const {
      title,
      semester,
      points,
      content,
      location,
      startTime,
      endTime,
      deadline,
      maxParticipants,
    } = req.body;

    if (!title || !semester || !startTime || !endTime) {
      return res.status(400).json({ message: "Thiếu dữ liệu bắt buộc" });
    }

    const act = new Activity({
      title,
      semester,
      points,
      content,
      location,
      startTime,
      endTime,
      deadline,
      maxParticipants,
      isClosed: false,
      createdBy: req.user.id,
    });

    await act.save();
    res.status(201).json({ message: "Tạo hoạt động thành công", act });
  } catch (e) {
    console.error("❌ Lỗi tạo hoạt động:", e);
    res.status(500).json({ message: e.message });
  }
});

/* =======================================================
   🧩 3️⃣ ADMIN CẬP NHẬT HOẠT ĐỘNG
   ======================================================= */
router.put("/:id", auth(["admin"]), async (req, res) => {
  try {
    const act = await Activity.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    if (!act) return res.status(404).json({ message: "Không tìm thấy hoạt động" });
    res.json({ message: "Cập nhật thành công", act });
  } catch (e) {
    console.error("❌ Lỗi cập nhật:", e);
    res.status(500).json({ message: e.message });
  }
});

/* =======================================================
   🧩 4️⃣ ADMIN XÓA HOẠT ĐỘNG
   ======================================================= */
router.delete("/:id", auth(["admin"]), async (req, res) => {
  try {
    const act = await Activity.findByIdAndDelete(req.params.id);
    if (!act) return res.status(404).json({ message: "Không tìm thấy hoạt động" });

    await Registration.deleteMany({ activity: act._id });
    res.json({ message: "Đã xóa hoạt động và đăng ký liên quan" });
  } catch (e) {
    console.error("❌ Lỗi xóa hoạt động:", e);
    res.status(500).json({ message: e.message });
  }
});

/* =======================================================
   🧩 5️⃣ SINH VIÊN ĐĂNG KÝ HOẠT ĐỘNG
   ======================================================= */
router.post("/:id/register", auth(["student"]), async (req, res) => {
  try {
    const activity = await Activity.findById(req.params.id);
    if (!activity)
      return res.status(404).json({ message: "Không tìm thấy hoạt động" });

    const now = new Date();

    if (activity.isClosed || activity.deadline < now) {
      return res.status(400).json({ message: "Form đã đóng" });
    }

    const count = await Registration.countDocuments({ activity: activity._id });
    if (count >= activity.maxParticipants) {
      activity.isClosed = true;
      await activity.save();
      return res.status(400).json({ message: "Đã đủ số lượng, form đã đóng" });
    }

    const existed = await Registration.findOne({
      user: req.user.id,
      activity: activity._id,
    });
    if (existed) {
      return res.status(400).json({ message: "Bạn đã đăng ký hoạt động này" });
    }

    await Registration.create({ user: req.user.id, activity: activity._id });
    res.json({ message: "Đăng ký thành công" });
  } catch (e) {
    console.error("❌ Lỗi đăng ký:", e);
    res.status(500).json({ message: e.message });
  }
});

/* =======================================================
   🧩 6️⃣ SINH VIÊN HỦY ĐĂNG KÝ HOẠT ĐỘNG
   ======================================================= */
router.post("/:id/unregister", auth(["student"]), async (req, res) => {
  try {
    const activity = await Activity.findById(req.params.id);
    if (!activity)
      return res.status(404).json({ message: "Không tìm thấy hoạt động" });

    const reg = await Registration.findOne({
      user: req.user.id,
      activity: activity._id,
    });

    if (!reg) {
      return res.status(400).json({ message: "Bạn chưa đăng ký hoạt động này" });
    }

    // Xóa bản ghi đăng ký
    await reg.deleteOne();

    // Nếu hoạt động đã đóng mà giờ còn chỗ & chưa quá hạn → mở lại
    const count = await Registration.countDocuments({ activity: activity._id });
    if (count < activity.maxParticipants && activity.deadline > new Date()) {
      activity.isClosed = false;
      await activity.save();
    }

    res.json({ message: "Hủy đăng ký thành công" });
  } catch (e) {
    console.error("❌ Lỗi hủy đăng ký:", e);
    res.status(500).json({ message: e.message });
  }
});

/* =======================================================
   🧩 7️⃣ SINH VIÊN XEM HOẠT ĐỘNG ĐÃ ĐĂNG KÝ
   ======================================================= */
router.get("/me/registrations", auth(["student"]), async (req, res) => {
  try {
    const regs = await Registration.find({ user: req.user.id })
      .sort({ createdAt: -1 })
      .populate("activity");
    res.json(regs);
  } catch (e) {
    console.error("❌ Lỗi xem danh sách đăng ký:", e);
    res.status(500).json({ message: e.message });
  }
});

export default router;
