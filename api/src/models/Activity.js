// api/models/Activity.js

import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const ActivitySchema = new Schema(
  {
    title: {
      type: String,
      required: [true, 'Tiêu đề là bắt buộc'],
    },
    description: {
      type: String,
      required: [true, 'Mô tả là bắt buộc'],
    },
    location: {
      type: String,
      required: [true, 'Địa điểm là bắt buộc'],
    },
    date: {
      type: Date, // Yêu cầu kiểu dữ liệu Date
      required: [true, 'Ngày diễn ra là bắt buộc'],
    },
    // (Bạn có thể thêm người tạo nếu muốn)
    // creator: {
    //   type: Schema.Types.ObjectId,
    //   ref: 'User',
    // },
  },
  {
    // Tự động thêm 'createdAt' và 'updatedAt'
    timestamps: true,
  }
);

// Quan trọng: Phải dùng 'export default'
export default mongoose.model('Activity', ActivitySchema);