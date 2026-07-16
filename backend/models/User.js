const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true, minlength: 4 },
  age: { type: Number, default: 0 },
  gender: { type: String, default: 'Not specified' },
  bloodGroup: { type: String, default: '' },
  phone: { type: String, default: '' },
  medicalHistory: { type: String, default: '' },
  photo: { type: String, default: '' },
  partnerName: { type: String, default: '' },
  tryingSince: { type: String, default: '' },
  previousIvfAttempts: { type: Number, default: 0 },
  menstrualCycleDays: { type: Number, default: 28 },
  height: { type: String, default: '' },
  weight: { type: String, default: '' },
  allergies: { type: String, default: '' },
  currentMedications: { type: String, default: '' },
  maritalStatus: { type: String, default: '' },
  profileComplete: { type: Boolean, default: false },
  likedBlogs: [{ type: String }],
  savedBlogs: [{ type: String }],
}, { timestamps: true });

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

userSchema.methods.comparePassword = async function (candidate) {
  return bcrypt.compare(candidate, this.password);
};

userSchema.methods.toPublicJSON = function () {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
