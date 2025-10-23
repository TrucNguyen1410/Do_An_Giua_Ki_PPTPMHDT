import mongoose from "mongoose";

const schema = new mongoose.Schema({
  title: { type: String, required: true },
  semester: { type: String, required: true },
  points: { type: Number, default: 0 },
  content: { type: String },
  location: { type: String, required: true },
  startTime: { type: Date, required: true },
  endTime: { type: Date, required: true },
  deadline: { type: Date, required: true },
  capacity: { type: Number, default: 100 },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  isClosed: { type: Boolean, default: false },
}, { timestamps: true });

schema.pre("save", function(next){
  const now = new Date();
  if (this.deadline < now) this.isClosed = true;
  next();
});

export default mongoose.model("Activity", schema);
