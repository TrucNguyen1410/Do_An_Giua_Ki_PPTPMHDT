import mongoose from "mongoose";

const attendanceSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  activity: { type: mongoose.Schema.Types.ObjectId, ref: "Activity", required: true },
  checkedInAt: { type: Date, default: Date.now }
}, { timestamps: true });

attendanceSchema.index({ user:1, activity:1 }, { unique: true });

export default mongoose.model("Attendance", attendanceSchema);
