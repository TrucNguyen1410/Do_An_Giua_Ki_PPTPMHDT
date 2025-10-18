import mongoose from "mongoose";

const registrationSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  activity: { type: mongoose.Schema.Types.ObjectId, ref: "Activity", required: true },
  status: { type: String, enum: ["pending", "approved"], default: "pending" }
}, { timestamps: true });

registrationSchema.index({ user:1, activity:1 }, { unique: true });

export default mongoose.model("Registration", registrationSchema);
