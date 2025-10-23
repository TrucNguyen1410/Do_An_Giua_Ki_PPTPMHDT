import mongoose from "mongoose";

const schema = new mongoose.Schema({
  name: { type: String, required: true },
  studentId: { type: String },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  role: { type: String, enum: ["student", "admin"], default: "student" },
}, { timestamps: true });

export default mongoose.model("User", schema);
