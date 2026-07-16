const mongoose = require('mongoose');

const labResultSchema = new mongoose.Schema({
  patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true },
  patientName: { type: String, required: true },
  doctorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor' },
  doctorName: { type: String },
  
  testType: { type: String, required: true }, // AMH, FSH, LH, Estradiol, Progesterone, etc.
  testCategory: { type: String, enum: ['hormone', 'genetic', 'infectious', 'semen', 'other'], required: true },
  
  testDate: { type: Date, required: true },
  reportDate: { type: Date },
  labName: { type: String, default: '' },
  
  results: {
    value: { type: String },
    unit: { type: String },
    referenceRange: { type: String },
    status: { type: String, enum: ['normal', 'abnormal', 'borderline', 'critical'] },
    notes: { type: String },
  },
  
  multipleResults: [{
    parameter: { type: String },
    value: { type: String },
    unit: { type: String },
    referenceRange: { type: String },
    status: { type: String },
  }],
  
  attachments: [{
    url: { type: String },
    name: { type: String },
    uploadDate: { type: Date },
  }],
  
  reviewedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor' },
  reviewedDate: { type: Date },
  reviewNotes: { type: String },
  
  isAbnormal: { type: Boolean, default: false },
  requiresFollowUp: { type: Boolean, default: false },
  followUpDate: { type: Date },
  
  notes: { type: String, default: '' },
}, { timestamps: true });

module.exports = mongoose.model('LabResult', labResultSchema);
