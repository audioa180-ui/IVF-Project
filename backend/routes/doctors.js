const express = require('express');
const Doctor = require('../models/Doctor');
const { authenticate, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// Public routes
router.get('/', async (req, res) => {
  try {
    const { search } = req.query;
    let filter = {};
    if (search) {
      const s = new RegExp(search, 'i');
      filter = { $or: [{ name: s }, { specialization: s }, { clinic: s }] };
    }
    const doctors = await Doctor.find(filter).sort({ rating: -1 });
    res.json(doctors);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id);
    if (!doctor) return res.status(404).json({ error: 'Doctor not found' });
    res.json(doctor);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Admin routes
router.get('/admin/all', requireAdmin, async (req, res) => {
  try {
    const { specialization, availableToday } = req.query;
    const filter = {};
    
    if (specialization) filter.specialization = specialization;
    if (availableToday !== undefined) filter.availableToday = availableToday === 'true';
    
    const doctors = await Doctor.find(filter).sort({ name: 1 });
    res.json(doctors);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/admin/:id', requireAdmin, async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id);
    if (!doctor) return res.status(404).json({ error: 'Doctor not found' });
    res.json(doctor);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post('/admin', requireAdmin, async (req, res) => {
  try {
    const doctor = await Doctor.create(req.body);
    res.status(201).json(doctor);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/admin/:id', requireAdmin, async (req, res) => {
  try {
    const doctor = await Doctor.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    );
    if (!doctor) return res.status(404).json({ error: 'Doctor not found' });
    res.json(doctor);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/admin/:id', requireAdmin, async (req, res) => {
  try {
    const doctor = await Doctor.findByIdAndDelete(req.params.id);
    if (!doctor) return res.status(404).json({ error: 'Doctor not found' });
    res.json({ message: 'Doctor deleted' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/admin/stats', requireAdmin, async (req, res) => {
  try {
    const total = await Doctor.countDocuments();
    const available = await Doctor.countDocuments({ availableToday: true });
    
    const bySpecialization = await Doctor.aggregate([
      { $group: { _id: '$specialization', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    const avgRating = await Doctor.aggregate([
      { $group: { _id: null, avgRating: { $avg: '$rating' } } }
    ]);
    
    res.json({
      total,
      available,
      bySpecialization,
      averageRating: avgRating[0]?.avgRating?.toFixed(2) || 0,
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
