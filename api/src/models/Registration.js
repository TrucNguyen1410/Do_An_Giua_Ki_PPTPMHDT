// lib/models/Registration.js

import mongoose from 'mongoose'; // <-- Sửa 'require' thành 'import'
const Schema = mongoose.Schema;

/**
 * Định nghĩa Schema cho việc đăng ký hoạt động
 * Liên kết giữa 'User' (sinh viên) và 'Activity' (hoạt động)
 */
const RegistrationSchema = new Schema({
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
  registeredAt: {
    type: Date,
    default: Date.now,
  },
  // 'attended' sẽ được cập nhật khi sinh viên quét QR điểm danh thành công
  attended: {
    type: Boolean,
    default: false,
  },
  // 'attendedAt' ghi lại thời điểm sinh viên điểm danh
  attendedAt: {
    type: Date,
    default: null,
  },
});

RegistrationSchema.index({ student: 1, activity: 1 }, { unique: true });

// Sửa 'module.exports =' thành 'export default'
export default mongoose.model('Registration', RegistrationSchema);