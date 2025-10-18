import mongoose from "mongoose";

const activitySchema = new mongoose.Schema(
  {
    // 🔹 Thông tin cơ bản
    title: { type: String, required: true },              // Tên hoạt động
    semester: { type: String, required: true },           // "HK1-2025" ...
    points: { type: Number, default: 0 },                 // Số điểm rèn luyện
    content: { type: String },                            // Nội dung chi tiết
    location: { type: String, required: true },           // Địa điểm

    // 🔹 Thời gian & đăng ký
    startTime: { type: Date, required: true },            // Thời gian bắt đầu
    endTime: { type: Date, required: true },              // Thời gian kết thúc
    deadline: { type: Date, required: true },             // Hạn đăng ký
    capacity: { type: Number, default: 100 },             // Giới hạn số lượng SV

    // 🔹 Quản lý
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" }, // Người tạo
    isClosed: { type: Boolean, default: false },           // Đã đóng form chưa
  },
  { timestamps: true }
);

// 🧠 Middleware: Tự động đóng hoạt động nếu quá hạn
activitySchema.pre("save", function (next) {
  const now = new Date();
  if (this.deadline < now) {
    this.isClosed = true;
  }
  next();
});

// 🧩 Virtual (tùy chọn): kiểm tra hoạt động đang mở
activitySchema.virtual("isOpen").get(function () {
  const now = new Date();
  return !this.isClosed && now <= this.deadline;
});

const Activity = mongoose.model("Activity", activitySchema);
export default Activity;
