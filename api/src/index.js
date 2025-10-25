// src/index.js
import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import cors from 'cors';

// Import các routes
import authRoutes from './routes/auth.js';
import activityRoutes from './routes/activities.js';
// import adminRoutes from './routes/admin.js'; // Bạn có thể import file này sau

// Cấu hình dotenv
dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

// Middlewares
app.use(cors());
app.use(express.json()); // Để parse JSON bodies

// Kết nối MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB đã kết nối thành công! (Connected to MongoDB)'))
  .catch(err => console.error('Lỗi kết nối MongoDB:', err));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/activities', activityRoutes);
// app.use('/api/admin', adminRoutes);

// Khởi động server
app.listen(PORT, () => {
  console.log(`Server đang chạy trên cổng ${PORT}`);
});