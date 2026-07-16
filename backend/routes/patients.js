const express = require('express');
const Patient = require('../models/Patient');
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

// Get all patients (Admin)
router.get('/admin/all', auth, async (req, res) => {
  try {
    const { status, search } = req.query;
    const filter = {};
    
    if (status) filter.status = status;
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
      ];
    }
    
    const patients = await Patient.find(filter)
      .populate('preferredDoctor', 'name')
      .sort({ createdAt: -1 });
    res.json(patients);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get patient details (Admin)
router.get('/admin/:id', auth, async (req, res) => {
  try {
    const patient = await Patient.findById(req.params.id)
      .populate('preferredDoctor', 'name qualification')
      .populate('partner');
    if (!patient) return res.status(404).json({ error: 'Patient not found' });
    res.json(patient);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Create patient (Admin)
router.post('/admin', auth, async (req, res) => {
  try {
    const patient = await Patient.create(req.body);
    res.status(201).json(patient);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update patient (Admin)
router.put('/admin/:id', auth, async (req, res) => {
  try {
    const patient = await Patient.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    );
    if (!patient) return res.status(404).json({ error: 'Patient not found' });
    res.json(patient);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete patient (Admin)
router.delete('/admin/:id', auth, async (req, res) => {
  try {
    const patient = await Patient.findByIdAndDelete(req.params.id);
    if (!patient) return res.status(404).json({ error: 'Patient not found' });
    res.json({ message: 'Patient deleted' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get patient statistics (Admin)
router.get('/admin/stats', auth, async (req, res) => {
  try {
    const total = await Patient.countDocuments();
    const active = await Patient.countDocuments({ status: 'active' });
    const inactive = await Patient.countDocuments({ status: 'inactive' });
    const archived = await Patient.countDocuments({ status: 'archived' });
    const profileComplete = await Patient.countDocuments({ profileComplete: true });
    
    // Active cycles
    const activeCycles = await Patient.countDocuments({ 'activeCycle.status': { $ne: null } });
    
    res.json({
      total,
      active,
      inactive,
      archived,
      profileComplete,
      activeCycles,
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
