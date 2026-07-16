const mongoose = require('mongoose');

const invoiceSchema = new mongoose.Schema({
  patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true },
  patientName: { type: String, required: true },
  patientEmail: { type: String, required: true },
  
  invoiceNumber: { type: String, required: true, unique: true },
  invoiceDate: { type: Date, required: true },
  dueDate: { type: Date, required: true },
  
  items: [{
    description: { type: String, required: true },
    quantity: { type: Number, required: true },
    unitPrice: { type: Number, required: true },
    total: { type: Number, required: true },
    category: { type: String }, // consultation, procedure, medication, lab, other
  }],
  
  subtotal: { type: Number, required: true },
  tax: { type: Number, default: 0 },
  discount: { type: Number, default: 0 },
  total: { type: Number, required: true },
  
  paymentStatus: { 
    type: String, 
    enum: ['pending', 'partial', 'paid', 'overdue', 'cancelled'],
    default: 'pending'
  },
  paymentMethod: { type: String }, // cash, card, insurance, transfer
  paidAmount: { type: Number, default: 0 },
  
  insurance: {
    provider: { type: String },
    policyNumber: { type: String },
    claimNumber: { type: String },
    coverageAmount: { type: Number },
  },
  
  notes: { type: String, default: '' },
  sentToPatient: { type: Boolean, default: false },
  sentDate: { type: Date },
}, { timestamps: true });

module.exports = mongoose.model('Invoice', invoiceSchema);
