import "dotenv/config";
import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import mongoose from "mongoose";
import bcrypt from "bcryptjs";

// 🧩 Import các router & model
import authRoutes from "./routes/auth.js";
import activitiesRoutes from "./routes/activities.js";
import adminRoutes from "./routes/admin.js";
import User from "./models/User.js";

// ========================================================
// ⚙️ 1️⃣ Khởi tạo ứng dụng Express
// ========================================================
const app = express();

// ========================================================
// ⚙️ 2️⃣ Middleware cấu hình chung
// ========================================================
app.use(
  cors({
    origin: (process.env.CORS_ORIGIN || "http://localhost:3000,http://10.0.2.2:3000").split(","),
    credentials: true,
  })
);
app.use(express.json());
app.use(cookieParser());

// ========================================================
// 🧩 3️⃣ Debug: Kiểm tra các router có được import đúng
// ========================================================
console.log("📦 Loaded routers:");
console.log("authRoutes:", typeof authRoutes);
console.log("activitiesRoutes:", typeof activitiesRoutes);
console.log("adminRoutes:", typeof adminRoutes);

// ========================================================
// 🚦 4️⃣ Đăng ký các route chính
// ========================================================
app.get("/", (_req, res) =>
  res.json({ ok: true, service: "🎓 CNIT Activities API đang hoạt động" })
);

app.use("/auth", authRoutes);
app.use("/activities", activitiesRoutes);
app.use("/admin", adminRoutes);

// ========================================================
// 🧠 5️⃣ Kết nối MongoDB & Tạo tài khoản admin mặc định
// ========================================================
const start = async () => {
  try {
    console.log("🔌 Connecting to MongoDB...");
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("✅ Connected to:", process.env.MONGODB_URI);

    // ⚙️ Seed admin mặc định
    const adminEmail = `admin@${process.env.ALLOWED_EMAIL_DOMAIN}`;
    const exists = await User.findOne({ email: adminEmail });
    if (!exists) {
      const passwordHash = await bcrypt.hash("Admin@123", 10);
      await User.create({
        name: "Admin Khoa CNTT",
        email: adminEmail,
        passwordHash,
        role: "admin",
      });
      console.log("👑 Seeded admin:", adminEmail, "pass=Admin@123");
    } else {
      console.log("✅ Admin account already exists:", adminEmail);
    }

    // ====================================================
    // 🚀 6️⃣ Khởi động server
    // ====================================================
    const port = process.env.PORT || 4000;
    app.listen(port, () =>
      console.log(`🚀 API server running at http://localhost:${port}`)
    );
  } catch (err) {
    console.error("❌ Error starting server:", err);
  }
};

// ========================================================
// 🔥 Gọi hàm start
// ========================================================
start();
