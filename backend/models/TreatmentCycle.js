const mongoose = require('mongoose');

const treatmentCycleSchema = new mongoose.Schema({
  patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true },
  patientName: { type: String, required: true },
  doctorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor', required: true },
  doctorName: { type: String, required: true },
  
  // Cycle Information
  cycleType: { type: String, enum: ['IVF', 'IUI', 'ICSI', 'FET', 'Egg Freezing'], required: true },
  protocol: { type: String, required: true }, // antagonist, agonist, natural, etc.
  startDate: { type: Date, required: true },
  endDate: { type: Date },
  currentDay: { type: Number, default: 1 },
  status: { 
    type: String, 
    enum: ['planned', 'active', 'paused', 'completed', 'cancelled', 'pregnant'],
    default: 'planned'
  },
  
  // Stimulation Phase
  stimulation: {
    startDate: { type: Date },
    endDate: { type: Date },
    medications: [{
      name: { type: String },
      dosage: { type: String },
      frequency: { type: String },
      startDate: { type: Date },
      endDate: { type: Date },
    }],
    monitoringScans: [{
      date: { type: Date },
      follicleCount: { type: Number },
      follicleSizes: [{ type: Number }],
      endometrialThickness: { type: Number },
      notes: { type: String },
    }],
  },
  
  // Trigger
  trigger: {
    date: { type: Date },
    medication: { type: String },
    dosage: { type: String },
    opuScheduled: { type: Date },
  },
  
  // OPU (Oocyte Pick-up)
  opu: {
    date: { type: Date },
    eggsRetrieved: { type: Number },
    matureEggs: { type: Number },
    complications: { type: String },
  },
  
  // Embryology
  embryology: {
    fertilizationMethod: { type: String }, // IVF, ICSI
    fertilized: { type: Number },
    day3Embryos: { type: Number },
    day5Blastocysts: { type: Number },
    cryopreserved: { type: Number },
    notes: { type: String },
  },
  
  // Transfer
  transfer: {
    date: { type: Date },
    type: { type: String }, // fresh, frozen
    embryosTransferred: { type: Number },
    embryoQuality: { type: String },
    complications: { type: String },
  },
  
  // Outcome
  outcome: {
    pregnancyTestDate: { type: Date },
    pregnancyTestResult: { type: String }, // positive, negative, pending
    hcgLevel: { type: Number },
    heartbeatDetected: { type: Boolean },
    deliveryDate: { type: Date },
    deliveryType: { type: String }, // vaginal, c-section
    babyCount: { type: Number },
    notes: { type: String },
  },
  
  // Costs
  costs: {
    estimatedCost: { type: Number },
    actualCost: { type: Number },
    insuranceCoverage: { type: Number },
    paymentStatus: { type: String, default: 'pending' },
  },
  
  notes: { type: String, default: '' },
}, { timestamps: true });

module.exports = mongoose.model('TreatmentCycle', treatmentCycleSchema);
