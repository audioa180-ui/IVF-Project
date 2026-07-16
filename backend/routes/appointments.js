const express = require('express');
const Appointment = require('../models/Appointment');

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

module.exports = router;
