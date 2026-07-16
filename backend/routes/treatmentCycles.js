const express = require('express');
const TreatmentCycle = require('../models/TreatmentCycle');
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
// Get patient's own treatment cycles
router.get('/patient', auth, async (req, res) => {
  try {
    const cycles = await TreatmentCycle.find({ patientId: req.user.userId })
      .sort({ startDate: -1 });
    res.json(cycles);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get specific treatment cycle details (patient can only view their own)
router.get('/:id', auth, async (req, res) => {
  try {
    const cycle = await TreatmentCycle.findById(req.params.id);
    if (!cycle) return res.status(404).json({ error: 'Treatment cycle not found' });
    // Only allow patient to view their own cycles
    if (cycle.patientId.toString() !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }
    res.json(cycle);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Admin routes
router.get('/admin/all', auth, async (req, res) => {
  try {
    const { status, cycleType, doctorId, patientId } = req.query;
    const filter = {};
    
    if (status) filter.status = status;
    if (cycleType) filter.cycleType = cycleType;
    if (doctorId) filter.doctorId = doctorId;
    if (patientId) filter.patientId = patientId;
    
    const cycles = await TreatmentCycle.find(filter)
      .populate('patientId', 'name email')
      .populate('doctorId', 'name')
      .sort({ startDate: -1 });
    res.json(cycles);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get treatment cycle details (Admin)
router.get('/admin/:id', auth, async (req, res) => {
  try {
    const cycle = await TreatmentCycle.findById(req.params.id)
      .populate('patientId', 'name email phone')
      .populate('doctorId', 'name qualification');
    if (!cycle) return res.status(404).json({ error: 'Treatment cycle not found' });
    res.json(cycle);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Create treatment cycle (Admin)
router.post('/admin', auth, async (req, res) => {
  try {
    const cycle = await TreatmentCycle.create(req.body);
    res.status(201).json(cycle);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update treatment cycle (Admin)
router.put('/admin/:id', auth, async (req, res) => {
  try {
    const cycle = await TreatmentCycle.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    );
    if (!cycle) return res.status(404).json({ error: 'Treatment cycle not found' });
    res.json(cycle);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update cycle status (Admin)
router.put('/admin/:id/status', auth, async (req, res) => {
  try {
    const { status } = req.body;
    const cycle = await TreatmentCycle.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    if (!cycle) return res.status(404).json({ error: 'Treatment cycle not found' });
    res.json(cycle);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Add monitoring scan (Admin)
router.post('/admin/:id/monitoring', auth, async (req, res) => {
  try {
    const cycle = await TreatmentCycle.findById(req.params.id);
    if (!cycle) return res.status(404).json({ error: 'Treatment cycle not found' });
    
    cycle.stimulation.monitoringScans.push(req.body);
    await cycle.save();
    res.json(cycle);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get treatment cycle statistics (Admin)
router.get('/admin/stats', auth, async (req, res) => {
  try {
    const total = await TreatmentCycle.countDocuments();
    const active = await TreatmentCycle.countDocuments({ status: 'active' });
    const completed = await TreatmentCycle.countDocuments({ status: 'completed' });
    const pregnant = await TreatmentCycle.countDocuments({ status: 'pregnant' });
    const cancelled = await TreatmentCycle.countDocuments({ status: 'cancelled' });
    
    // By cycle type
    const byType = await TreatmentCycle.aggregate([
      { $group: { _id: '$cycleType', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    // Success rate
    const successRate = total > 0 ? (pregnant / total * 100).toFixed(2) : 0;
    
    res.json({
      total,
      active,
      completed,
      pregnant,
      cancelled,
      byType,
      successRate,
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
