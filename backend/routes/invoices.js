const express = require('express');
const Invoice = require('../models/Invoice');
const router = express.Router();
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'bloom_ivf_jwt_secret_dev';

function auth(req, res, next) {
  const header = req.headers.authorization;
  if (!header) return res.status(401).json({ error: 'No token provided' });
  try {
    req.user = jwt.verify(header.replace('Bearer ', ''), JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Invalid token' });
  }
}

// Patient routes
// Get patient's own invoices
router.get('/patient', auth, async (req, res) => {
  try {
    const invoices = await Invoice.find({ patientId: req.user.userId })
      .sort({ invoiceDate: -1 });
    res.json(invoices);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get specific invoice details (patient can only view their own)
router.get('/:id', auth, async (req, res) => {
  try {
    const invoice = await Invoice.findById(req.params.id);
    if (!invoice) return res.status(404).json({ error: 'Invoice not found' });
    // Only allow patient to view their own invoices
    if (invoice.patientId.toString() !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }
    res.json(invoice);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Admin routes
router.get('/admin/all', auth, async (req, res) => {
  try {
    const { patientId, paymentStatus, startDate, endDate } = req.query;
    const filter = {};
    
    if (patientId) filter.patientId = patientId;
    if (paymentStatus) filter.paymentStatus = paymentStatus;
    if (startDate && endDate) {
      filter.invoiceDate = {
        $gte: new Date(startDate),
        $lte: new Date(endDate),
      };
    }
    
    const invoices = await Invoice.find(filter)
      .populate('patientId', 'name email')
      .sort({ invoiceDate: -1 });
    res.json(invoices);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get invoice details (Admin)
router.get('/admin/:id', auth, async (req, res) => {
  try {
    const invoice = await Invoice.findById(req.params.id)
      .populate('patientId', 'name email phone');
    if (!invoice) return res.status(404).json({ error: 'Invoice not found' });
    res.json(invoice);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Create invoice (Admin)
router.post('/admin', auth, async (req, res) => {
  try {
    const invoice = await Invoice.create(req.body);
    res.status(201).json(invoice);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update invoice (Admin)
router.put('/admin/:id', auth, async (req, res) => {
  try {
    const invoice = await Invoice.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    );
    if (!invoice) return res.status(404).json({ error: 'Invoice not found' });
    res.json(invoice);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update payment status (Admin)
router.put('/admin/:id/payment', auth, async (req, res) => {
  try {
    const { paymentStatus, paidAmount, paymentMethod } = req.body;
    const invoice = await Invoice.findByIdAndUpdate(
      req.params.id,
      {
        paymentStatus,
        paidAmount,
        paymentMethod,
      },
      { new: true }
    );
    if (!invoice) return res.status(404).json({ error: 'Invoice not found' });
    res.json(invoice);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete invoice (Admin)
router.delete('/admin/:id', auth, async (req, res) => {
  try {
    const invoice = await Invoice.findByIdAndDelete(req.params.id);
    if (!invoice) return res.status(404).json({ error: 'Invoice not found' });
    res.json({ message: 'Invoice deleted' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get invoice statistics (Admin)
router.get('/admin/stats', auth, async (req, res) => {
  try {
    const total = await Invoice.countDocuments();
    const pending = await Invoice.countDocuments({ paymentStatus: 'pending' });
    const paid = await Invoice.countDocuments({ paymentStatus: 'paid' });
    const overdue = await Invoice.countDocuments({ paymentStatus: 'overdue' });
    
    // Total revenue
    const revenue = await Invoice.aggregate([
      { $match: { paymentStatus: 'paid' } },
      { $group: { _id: null, total: { $sum: '$total' } } }
    ]);
    
    // Outstanding amount
    const outstanding = await Invoice.aggregate([
      { $match: { paymentStatus: { $in: ['pending', 'partial'] } } },
      { $group: { _id: null, total: { $sum: { $subtract: ['$total', '$paidAmount'] } } } }
    ]);
    
    res.json({
      total,
      pending,
      paid,
      overdue,
      totalRevenue: revenue[0]?.total || 0,
      outstandingAmount: outstanding[0]?.total || 0,
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
