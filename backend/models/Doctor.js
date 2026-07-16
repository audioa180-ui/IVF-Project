const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  patientName: { type: String, default: '' },
  rating: { type: Number, default: 5 },
  comment: { type: String, default: '' },
  date: { type: String, default: '' },
}, { _id: false });

const doctorSchema = new mongoose.Schema({
  name: { type: String, required: true },
  photo: { type: String, default: '' },
  qualification: { type: String, default: '' },
  experience: { type: Number, default: 0 },
  specialization: { type: String, default: '' },
  rating: { type: Number, default: 4.5 },
  reviewCount: { type: Number, default: 0 },
  languages: [{ type: String }],
  availableToday: { type: Boolean, default: true },
  clinic: { type: String, default: '' },
  about: { type: String, default: '' },
  education: [{ type: String }],
  successRate: { type: Number, default: 0 },
  consultationFee: { type: Number, default: 0 },
  availableSlots: [{ type: String }],
  reviews: [reviewSchema],
}, { timestamps: true });

module.exports = mongoose.model('Doctor', doctorSchema);
