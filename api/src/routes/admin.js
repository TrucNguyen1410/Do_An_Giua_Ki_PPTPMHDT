import express from "express";
import { auth } from "../middlewares/auth.js";
import Activity from "../models/Activity.js";
import Registration from "../models/Registration.js";

const router = express.Router();

// 🧩 1️⃣ Admin: Lấy danh sách hoạt động
router.get("/activities", auth(["admin"]), async (req, res) => {
  const list = await Activity.find().sort({ createdAt: -1 });
  res.json(list);
});

// 🧩 2️⃣ Admin: Thêm hoạt động mới
router.post("/activities", auth(["admin"]), async (req, res) => {
  try {
    const data = req.body;

    // Kiểm tra dữ liệu tối thiểu
    if (
      !data.title ||
      !data.semester ||
      !data.startTime ||
      !data.endTime ||
      !data.deadline
    ) {
      return res.status(400).json({ message: "Thiếu thông tin bắt buộc" });
    }

    // Tạo hoạt động
    const newActivity = await Activity.create({
      title: data.title,
      semester: data.semester,
      points: data.points || 0,
      content: data.content || "",
      location: data.location || "Chưa xác định",
      startTime: new Date(data.startTime),
      endTime: new Date(data.endTime),
      deadline: new Date(data.deadline),
      capacity: data.capacity || 100,
      createdBy: req.user.id,
    });

    res.json({ message: "Tạo hoạt động thành công", activity: newActivity });
  } catch (err) {
    console.error("❌ Lỗi khi tạo hoạt động:", err);
    res.status(500).json({ message: "Lỗi khi tạo hoạt động" });
  }
});

// 🧩 3️⃣ Admin: Cập nhật hoạt động
router.put("/activities/:id", auth(["admin"]), async (req, res) => {
  try {
    const activity = await Activity.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    if (!activity)
      return res.status(404).json({ message: "Không tìm thấy hoạt động" });
    res.json({ message: "Cập nhật thành công", activity });
  } catch (err) {
    console.error("❌ Lỗi cập nhật:", err);
    res.status(500).json({ message: "Lỗi khi cập nhật hoạt động" });
  }
});

// 🧩 4️⃣ Admin: Xóa hoạt động
router.delete("/activities/:id", auth(["admin"]), async (req, res) => {
  try {
    await Activity.findByIdAndDelete(req.params.id);
    await Registration.deleteMany({ activity: req.params.id });
    res.json({ message: "Đã xóa hoạt động" });
  } catch (err) {
    console.error("❌ Lỗi khi xóa hoạt động:", err);
    res.status(500).json({ message: "Lỗi khi xóa hoạt động" });
  }
});

// 🧩 5️⃣ Middleware kiểm tra hoạt động hết hạn hoặc đủ số lượng
router.post("/activities/:id/check-close", auth(["admin"]), async (req, res) => {
  try {
    const act = await Activity.findById(req.params.id);
    if (!act) return res.status(404).json({ message: "Không tìm thấy hoạt động" });

    const now = new Date();
    const count = await Registration.countDocuments({ activity: act._id });

    if (count >= act.capacity || act.deadline < now) {
      act.isClosed = true;
      await act.save();
      return res.json({ closed: true, reason: "Đủ số lượng hoặc quá hạn" });
    }

    res.json({ closed: false });
  } catch (err) {
    console.error("❌ Lỗi check close:", err);
    res.status(500).json({ message: "Lỗi kiểm tra đóng hoạt động" });
  }
});

export default router;
