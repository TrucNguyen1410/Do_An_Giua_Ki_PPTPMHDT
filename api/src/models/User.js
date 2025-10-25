// src/models/User.js
import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      enum: ['student', 'admin'],
      default: 'student',
    },
  },
  {
    timestamps: true, // Tự động thêm createdAt và updatedAt
  }
);

// Dùng 'export default' thay vì 'module.exports'
export default mongoose.model('User', userSchema);