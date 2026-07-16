const express = require('express');
const Appointment = require('../models/Appointment');

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
router.get('/', auth, async (req, res) => {
  try {
    const appointments = await Appointment.find({ userId: req.user.id }).sort({ date: -1 });
    res.json(appointments);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post('/', auth, async (req, res) => {
  try {
    const { doctorId, doctorName, clinic, date, time } = req.body;
    const appointment = await Appointment.create({
      userId: req.user.id, doctorId, doctorName, clinic,
      date: new Date(date), time, status: 'upcoming'
    });
    res.status(201).json(appointment);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/:id', auth, async (req, res) => {
  try {
    const appointment = await Appointment.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { $set: req.body },
      { new: true }
    );
    if (!appointment) return res.status(404).json({ error: 'Appointment not found' });
    res.json(appointment);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.delete('/:id', auth, async (req, res) => {
  try {
    const appointment = await Appointment.findOneAndDelete(
      { _id: req.params.id, userId: req.user.id }
    );
    if (!appointment) return res.status(404).json({ error: 'Appointment not found' });
    res.json({ message: 'Cancelled' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Admin routes - get all appointments with optional filters
router.get('/admin/all', requireAdmin, async (req, res) => {
  try {
    const { doctorId, userId, status, startDate, endDate } = req.query;
    const filter = {};
    
    if (doctorId) filter.doctorId = doctorId;
    if (userId) filter.userId = userId;
    if (status) filter.status = status;
    if (startDate || endDate) {
      filter.date = {};
      if (startDate) filter.date.$gte = new Date(startDate);
      if (endDate) filter.date.$lte = new Date(endDate);
    }
    
    const appointments = await Appointment.find(filter)
      .sort({ date: -1, time: -1 })
      .populate('userId', 'name email');
    res.json(appointments);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Admin route - update appointment status
router.put('/admin/:id/status', requireAdmin, async (req, res) => {
  try {
    const { status } = req.body;
    const appointment = await Appointment.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    if (!appointment) return res.status(404).json({ error: 'Appointment not found' });
    res.json(appointment);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Admin route - get appointment statistics
router.get('/admin/stats', requireAdmin, async (req, res) => {
  try {
    const total = await Appointment.countDocuments();
    const upcoming = await Appointment.countDocuments({ status: 'upcoming' });
    const completed = await Appointment.countDocuments({ status: 'completed' });
    const cancelled = await Appointment.countDocuments({ status: 'cancelled' });
    
    // Get appointments by doctor
    const byDoctor = await Appointment.aggregate([
      { $group: { _id: '$doctorName', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    // Get upcoming appointments in next 7 days
    const nextWeek = new Date();
    nextWeek.setDate(nextWeek.getDate() + 7);
    const upcomingThisWeek = await Appointment.countDocuments({
      status: 'upcoming',
      date: { $gte: new Date(), $lte: nextWeek }
    });
    
    res.json({
      total,
      upcoming,
      completed,
      cancelled,
      byDoctor,
      upcomingThisWeek
    });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
