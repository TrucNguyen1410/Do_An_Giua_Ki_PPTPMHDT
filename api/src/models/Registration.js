// src/models/Registration.js
import mongoose from 'mongoose';
const { Schema } = mongoose;

const registrationSchema = new Schema(
  {
    student: {
      type: Schema.Types.ObjectId,
      ref: 'User', // Tham chiếu đến model 'User'
      required: true,
    },
    activity: {
      type: Schema.Types.ObjectId,
      ref: 'Activity', // Tham chiếu đến model 'Activity'
      required: true,
    },
    // --- THÊM TRƯỜNG NÀY VÀO ĐỂ ĐIỂM DANH ---
    attended: {
      type: Boolean,
      default: false, // Mặc định là 'chưa tham dự'
    },
  },
  {
    timestamps: true,
  }
);

// Đảm bảo sinh viên không thể đăng ký 1 hoạt động 2 lần
registrationSchema.index({ student: 1, activity: 1 }, { unique: true });

// Dùng 'export default' thay vì 'module.exports'
export default mongoose.model('Registration', registrationSchema);
