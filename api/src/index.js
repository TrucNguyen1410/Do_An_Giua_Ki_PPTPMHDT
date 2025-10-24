// api/src/index.js

import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import cors from 'cors'; // QUAN TRỌNG: Để Flutter App gọi được API

// Import các routes (đã sửa sang ESM)
import authRoutes from './routes/auth.js';
import adminRoutes from './routes/admin.js';
// (Bạn cần tạo và import file activities.js cho các route của student)
// import activityRoutes from './routes/activities.js'; 

// === CÀI ĐẶT ===
dotenv.config(); // Đọc file .env
const app = express();
// Đọc cổng từ file .env, nếu không có thì mặc định là 4000
const PORT = process.env.PORT || 4000; 

// === KẾT NỐI MONGODB ===
const connectDB = async () => {
  try {
    // Đảm bảo file .env của bạn có MONGO_URI
    await mongoose.connect(process.env.MONGO_URI);
    // Đây là log chính xác
    console.log('MongoDB đã kết nối thành công! (Connected to MongoDB)'); 
  } catch (err) {
    console.error('Lỗi kết nối MongoDB:', err.message);
    process.exit(1);
  }
};
connectDB(); // Gọi hàm kết nối

// === MIDDLEWARES ===
app.use(cors()); // <-- DÒNG BỊ THIẾU
app.use(express.json()); // Cho phép server đọc req.body dạng JSON

// === ĐỊNH NGHĨA ROUTES ===
// Đây là phần quan trọng nhất bị thiếu
app.use('/api/auth', authRoutes); // <-- DÒNG BỊ THIẾU
app.use('/api/admin', adminRoutes);
// app.use('/api/activities', activitiesRoutes);

// Route cơ bản để kiểm tra
app.get('/', (req, res) => res.send('API đang chạy...'));

// === KHỞI ĐỘNG SERVER ===
app.listen(PORT, () => {
  console.log(`Server đang chạy trên cổng ${PORT}`);
});