const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  email: { type: String, required: true },
  phone: { type: String, default: '' },
  dateOfBirth: { type: Date },
  bloodType: { type: String, default: '' },
  address: { type: String, default: '' },
  emergencyContact: {
    name: { type: String, default: '' },
    phone: { type: String, default: '' },
    relationship: { type: String, default: '' },
  },
  partner: {
    name: { type: String, default: '' },
    email: { type: String, default: '' },
    phone: { type: String, default: '' },
    dateOfBirth: { type: Date },
  },
  medicalHistory: {
    previousTreatments: [{ type: String }],
    allergies: [{ type: String }],
    medications: [{ type: String }],
    chronicConditions: [{ type: String }],
  },
  fertilityProfile: {
    amhLevel: { type: Number },
    afcCount: { type: Number },
    fshLevel: { type: Number },
    lhLevel: { type: Number },
    estradiolLevel: { type: Number },
    lastUpdated: { type: Date },
  },
  treatmentHistory: [{
    type: { type: String }, // IVF, IUI, ICSI, etc.
    startDate: { type: Date },
    endDate: { type: Date },
    outcome: { type: String }, // success, failed, ongoing
    notes: { type: String },
  }],
  activeCycle: {
    cycleId: { type: String },
    protocol: { type: String },
    startDate: { type: Date },
    currentDay: { type: Number },
    status: { type: String }, // stimulation, monitoring, trigger, retrieval, transfer, waiting
    medications: [{
      name: { type: String },
      dosage: { type: String },
      frequency: { type: String },
      startDate: { type: Date },
      endDate: { type: Date },
    }],
  },
  documents: [{
    type: { type: String }, // lab report, consent, scan, etc.
    url: { type: String },
    name: { type: String },
    uploadDate: { type: Date },
  }],
  insurance: {
    provider: { type: String, default: '' },
    policyNumber: { type: String, default: '' },
    coverageDetails: { type: String, default: '' },
  },
  preferences: {
    preferredDoctor: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor' },
    preferredClinic: { type: String, default: '' },
    communicationMethod: { type: String, default: 'email' }, // email, sms, whatsapp
  },
  status: { type: String, enum: ['active', 'inactive', 'archived'], default: 'active' },
  profileComplete: { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('Patient', patientSchema);
