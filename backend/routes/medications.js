const express = require('express');
const Medication = require('../models/Medication');
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

// Get all medications (Admin)
router.get('/admin/all', auth, async (req, res) => {
  try {
    const { category, isActive, lowStock } = req.query;
    const filter = {};
    
    if (category) filter.category = category;
    if (isActive !== undefined) filter.isActive = isActive === 'true';
    if (lowStock === 'true') {
      filter.$expr = { $lte: ['$stock', '$minStockLevel'] };
    }
    
    const medications = await Medication.find(filter).sort({ name: 1 });
    res.json(medications);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get medication details (Admin)
router.get('/admin/:id', auth, async (req, res) => {
  try {
    const medication = await Medication.findById(req.params.id);
    if (!medication) return res.status(404).json({ error: 'Medication not found' });
    res.json(medication);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Create medication (Admin)
router.post('/admin', auth, async (req, res) => {
  try {
    const medication = await Medication.create(req.body);
    res.status(201).json(medication);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update medication (Admin)
router.put('/admin/:id', auth, async (req, res) => {
  try {
    const medication = await Medication.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    );
    if (!medication) return res.status(404).json({ error: 'Medication not found' });
    res.json(medication);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete medication (Admin)
router.delete('/admin/:id', auth, async (req, res) => {
  try {
    const medication = await Medication.findByIdAndDelete(req.params.id);
    if (!medication) return res.status(404).json({ error: 'Medication not found' });
    res.json({ message: 'Medication deleted' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update stock (Admin)
router.put('/admin/:id/stock', auth, async (req, res) => {
  try {
    const { stock } = req.body;
    const medication = await Medication.findByIdAndUpdate(
      req.params.id,
      { stock },
      { new: true }
    );
    if (!medication) return res.status(404).json({ error: 'Medication not found' });
    res.json(medication);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get medication statistics (Admin)
router.get('/admin/stats', auth, async (req, res) => {
  try {
    const total = await Medication.countDocuments();
    const active = await Medication.countDocuments({ isActive: true });
    
    // Get all medications and filter for low stock
    const allMedications = await Medication.find({});
    const lowStock = allMedications.filter(med => med.stock <= med.minStockLevel).length;
    
    // By category
    const byCategory = await Medication.aggregate([
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    // Expiring soon (within 30 days)
    const thirtyDaysFromNow = new Date();
    thirtyDaysFromNow.setDate(thirtyDaysFromNow.getDate() + 30);
    const expiringSoon = await Medication.countDocuments({
      expiryDate: { $lte: thirtyDaysFromNow, $gte: new Date() }
    });
    
    res.json({
      total,
      active,
      lowStock,
      expiringSoon,
      byCategory,
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
