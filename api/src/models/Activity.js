// src/models/Activity.js
import mongoose from 'mongoose';
const { Schema } = mongoose;

const activitySchema = new Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
    },
    location: {
      type: String,
      required: true,
    },

    // --- 1. XÓA 'date' CŨ, THÊM 3 TRƯỜNG DATE MỚI ---
    startDate: {
      // Ngày/Giờ hoạt động bắt đầu
      type: Date,
      required: true,
    },
    endDate: {
      // Ngày/Giờ hoạt động kết thúc
      type: Date,
      required: true,
    },
    registrationDeadline: {
      // Hạn chót đăng ký (có giờ)
      type: Date,
      required: true,
    },
    // ------------------------------------------------

    maxParticipants: {
      type: Number,
      default: 0, // 0 = không giới hạn
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// --- 3. TRƯỜNG ẢO ĐỂ ĐẾM SỐ LƯỢNG (Giữ nguyên) ---
activitySchema.virtual('participantCount', {
  ref: 'Registration', // Model để đếm
  localField: '_id', // Trường của Activity (this)
  foreignField: 'activity', // Trường của Registration
  count: true, // Chỉ đếm
});

export default mongoose.model('Activity', activitySchema);