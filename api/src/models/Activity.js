// src/models/Activity.js
import mongoose from 'mongoose';

const activitySchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },
    date: {
      type: Date,
      required: true,
    },
    location: {
      type: String,
      required: true,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

// Dùng 'export default' thay vì 'module.exports'
export default mongoose.model('Activity', activitySchema);