const mongoose = require('mongoose');

const medicationSchema = new mongoose.Schema({
  name: { type: String, required: true },
  genericName: { type: String, default: '' },
  category: { type: String, enum: ['fertility', 'hormone', 'antibiotic', 'painkiller', 'supplement', 'other'], required: true },
  description: { type: String, default: '' },
  manufacturer: { type: String, default: '' },
  dosageForms: [{ type: String }], // tablet, injection, liquid, etc.
  strength: { type: String, default: '' }, // 50mg, 100IU, etc.
  stock: { type: Number, default: 0 },
  minStockLevel: { type: Number, default: 10 },
  price: { type: Number, default: 0 },
  expiryDate: { type: Date },
  batchNumber: { type: String, default: '' },
  storageConditions: { type: String, default: '' },
  sideEffects: [{ type: String }],
  contraindications: [{ type: String }],
  isActive: { type: Boolean, default: true },
}, { timestamps: true });

module.exports = mongoose.model('Medication', medicationSchema);
