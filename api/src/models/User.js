import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  studentId: { type: String, trim: true }, // MSSV (bắt buộc với role student)
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  passwordHash: { type: String, required: true },
  role: { type: String, enum: ["student", "admin"], default: "student" },
  verified: { type: Boolean, default: true } // MVP: true luôn (có thể gửi mail verify sau)
}, { timestamps: true });

export default mongoose.model("User", userSchema);
