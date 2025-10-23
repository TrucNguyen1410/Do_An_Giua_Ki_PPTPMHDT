import "dotenv/config";
import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import mongoose from "mongoose";
import bcrypt from "bcryptjs";

import authRoutes from "./routes/auth.js";
import activitiesRoutes from "./routes/activities.js";
import adminRoutes from "./routes/admin.js";
import User from "./models/User.js";

const app = express();
app.use(cors({
  origin: (process.env.CORS_ORIGIN || "").split(","),
  credentials: true,
}));
app.use(express.json());
app.use(cookieParser());

app.get("/", (_req, res) => res.json({ ok: true, service: "CNIT Activities API" }));
app.use("/auth", authRoutes);
app.use("/activities", activitiesRoutes);
app.use("/admin", adminRoutes);

const start = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("✅ Connected:", process.env.MONGODB_URI);

    // seed admin
    const adminEmail = `admin@${process.env.ALLOWED_EMAIL_DOMAIN}`;
    const exists = await User.findOne({ email: adminEmail });
    if (!exists) {
      const passwordHash = await bcrypt.hash("Admin@123", 10);
      await User.create({
        name: "Admin Khoa CNTT",
        email: adminEmail,
        role: "admin",
        passwordHash,
      });
      console.log("👑 Seeded admin:", adminEmail, "pass=Admin@123");
    }

    app.listen(process.env.PORT, () =>
      console.log(`🚀 API running at http://localhost:${process.env.PORT}`)
    );
  } catch (e) {
    console.error("❌ Error:", e);
  }
};

start();
