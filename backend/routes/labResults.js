const express = require('express');
const LabResult = require('../models/LabResult');
const Patient = require('../models/Patient');
const router = express.Router();
const jwt = require('jsonwebtoken');
const { requireAdmin } = require('../middleware/auth');

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
// Get patient's own lab results
router.get('/patient', auth, async (req, res) => {
  try {
    const patient = await Patient.findOne({ userId: req.user.id });
    if (!patient) return res.json([]);
    const results = await LabResult.find({ patientId: patient._id })
      .sort({ testDate: -1 });
    res.json(results);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get specific lab result details (patient can only view their own)
router.get('/:id', auth, async (req, res) => {
  try {
    const result = await LabResult.findById(req.params.id);
    if (!result) return res.status(404).json({ error: 'Lab result not found' });
    // Only allow patient to view their own results
    const patient = await Patient.findOne({ userId: req.user.id });
    if (!patient || result.patientId.toString() !== patient._id.toString()) {
      return res.status(403).json({ error: 'Access denied' });
    }
    res.json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Admin routes
router.get('/admin/all', requireAdmin, async (req, res) => {
  try {
    const { patientId, testType, testCategory, isAbnormal } = req.query;
    const filter = {};
    
    if (patientId) filter.patientId = patientId;
    if (testType) filter.testType = testType;
    if (testCategory) filter.testCategory = testCategory;
    if (isAbnormal !== undefined) filter.isAbnormal = isAbnormal === 'true';
    
    const results = await LabResult.find(filter)
      .populate('patientId', 'name email')
      .populate('doctorId', 'name')
      .populate('reviewedBy', 'name')
      .sort({ testDate: -1 });
    res.json(results);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get lab result details (Admin)
router.get('/admin/:id', requireAdmin, async (req, res) => {
  try {
    const result = await LabResult.findById(req.params.id)
      .populate('patientId', 'name email phone')
      .populate('doctorId', 'name qualification')
      .populate('reviewedBy', 'name');
    if (!result) return res.status(404).json({ error: 'Lab result not found' });
    res.json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Create lab result (Admin)
router.post('/admin', requireAdmin, async (req, res) => {
  try {
    const result = await LabResult.create(req.body);
    res.status(201).json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update lab result (Admin)
router.put('/admin/:id', requireAdmin, async (req, res) => {
  try {
    const result = await LabResult.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    );
    if (!result) return res.status(404).json({ error: 'Lab result not found' });
    res.json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Review lab result (Admin/Doctor)
router.put('/admin/:id/review', requireAdmin, async (req, res) => {
  try {
    const { reviewedBy, reviewNotes } = req.body;
    const result = await LabResult.findByIdAndUpdate(
      req.params.id,
      {
        reviewedBy,
        reviewNotes,
        reviewedDate: new Date(),
      },
      { new: true }
    );
    if (!result) return res.status(404).json({ error: 'Lab result not found' });
    res.json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete lab result (Admin)
router.delete('/admin/:id', requireAdmin, async (req, res) => {
  try {
    const result = await LabResult.findByIdAndDelete(req.params.id);
    if (!result) return res.status(404).json({ error: 'Lab result not found' });
    res.json({ message: 'Lab result deleted' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get lab result statistics (Admin)
router.get('/admin/stats', requireAdmin, async (req, res) => {
  try {
    const total = await LabResult.countDocuments();
    const abnormal = await LabResult.countDocuments({ isAbnormal: true });
    const requiresFollowUp = await LabResult.countDocuments({ requiresFollowUp: true });
    const reviewed = await LabResult.countDocuments({ reviewedBy: { $ne: null } });
    
    // By test category
    const byCategory = await LabResult.aggregate([
      { $group: { _id: '$testCategory', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    // By test type
    const byType = await LabResult.aggregate([
      { $group: { _id: '$testType', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    res.json({
      total,
      abnormal,
      requiresFollowUp,
      reviewed,
      byCategory,
      byType,
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
