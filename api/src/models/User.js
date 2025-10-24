// lib/models/User.js

import mongoose from 'mongoose'; // <-- Sửa 'require' thành 'import'
const Schema = mongoose.Schema;

/**
 * Định nghĩa Schema cho người dùng (User)
 */
const UserSchema = new Schema({
  fullName: {
    type: String,
    required: [true, 'Họ tên là bắt buộc'],
  },
  email: {
    type: String,
    required: [true, 'Email là bắt buộc'],
    unique: true,
    trim: true,
    lowercase: true,
    match: [/\S+@\S+\.\S+/, 'Email không hợp lệ'],
  },
  password: {
    type: String,
    required: [true, 'Mật khẩu là bắt buộc'],
  },
  role: {
    type: String,
    enum: ['student', 'admin'],
    default: 'student',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Sửa 'module.exports =' thành 'export default'
export default mongoose.model('User', UserSchema);