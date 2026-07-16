const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Patient = require('../models/Patient');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'bloom_ivf_jwt_secret_dev';

async function ensurePatientProfile(user) {
  return Patient.findOneAndUpdate(
    { userId: user._id },
    {
      $set: {
        name: user.name,
        email: user.email,
        phone: user.phone || '',
        profileComplete: Boolean(user.profileComplete),
      },
      $setOnInsert: { status: 'active' },
    },
    { upsert: true, new: true, setDefaultsOnInsert: true },
  );
}

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

router.post('/register', async (req, res) => {
  try {
    const { name, email, password, gender, photo } = req.body;
    if (await User.findOne({ email: email.toLowerCase() })) {
      return res.status(400).json({ error: 'Email already registered' });
    }
    const user = await User.create({ name, email, password, gender: gender || 'Female', photo: photo || '' });
    // The clinic workspace uses Patient records while the mobile app uses User
    // accounts. Create the linked profile immediately so both clients always
    // refer to the same person.
    await ensurePatientProfile(user);
    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '30d' });
    res.status(201).json({ token, user: user.toPublicJSON() });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    await ensurePatientProfile(user);
    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '30d' });
    res.json({ token, user: user.toPublicJSON() });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/me', auth, async (req, res) => {
  const user = await User.findById(req.user.id);
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user.toPublicJSON());
});

router.put('/me', auth, async (req, res) => {
  const allowed = [
    'name', 'age', 'gender', 'bloodGroup', 'phone', 'medicalHistory',
    'photo', 'partnerName', 'tryingSince', 'previousIvfAttempts',
    'menstrualCycleDays', 'height', 'weight', 'allergies',
    'currentMedications', 'maritalStatus', 'profileComplete'
  ];
  const updates = {};
  for (const key of allowed) {
    if (req.body[key] !== undefined) updates[key] = req.body[key];
  }
  const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true });
  await ensurePatientProfile(user);
  res.json(user.toPublicJSON());
});

module.exports = router;
