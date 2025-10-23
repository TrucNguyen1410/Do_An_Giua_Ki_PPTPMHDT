import mongoose from "mongoose";

const schema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  activity: { type: mongoose.Schema.Types.ObjectId, ref: "Activity", required: true },
}, { timestamps: true });

schema.index({ user: 1, activity: 1 }, { unique: true });

export default mongoose.model("Registration", schema);
