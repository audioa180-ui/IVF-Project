const express = require('express');
const router = express.Router();
const Admin = require('../models/Admin');
const User = require('../models/User');
const Doctor = require('../models/Doctor');
const Appointment = require('../models/Appointment');
const Blog = require('../models/Blog');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'bloom_ivf_jwt_secret_dev';

// Middleware to verify admin token and check role
const verifyAdmin = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Access denied' });
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (!decoded.role || !['admin', 'master'].includes(decoded.role)) {
      return res.status(403).json({ error: 'Administrator access is required' });
    }
    req.admin = decoded;
    next();
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

const verifyMasterAdmin = (req, res, next) => {
  if (req.admin.role !== 'master') {
    return res.status(403).json({ error: 'Master admin access required' });
  }
  next();
};

// Admin login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const admin = await Admin.findOne({ email, isActive: true });
    
    if (!admin || !(await admin.comparePassword(password))) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    admin.lastLogin = new Date();
    await admin.save();
    
    const token = jwt.sign(
      { id: admin._id, email: admin.email, role: admin.role },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.json({
      token,
      admin: {
        id: admin._id,
        name: admin.name,
        email: admin.email,
        role: admin.role,
        lastLogin: admin.lastLogin
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get dashboard stats
router.get('/dashboard', verifyAdmin, async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalDoctors = await Doctor.countDocuments();
    const totalAppointments = await Appointment.countDocuments();
    const totalBlogs = await Blog.countDocuments();
    
    const recentUsers = await User.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .select('name email createdAt profileComplete');
    
    const upcomingAppointments = await Appointment.find({ status: 'upcoming' })
      .sort({ date: 1 })
      .limit(5)
      .populate('userId', 'name email');
    
    res.json({
      stats: {
        totalUsers,
        totalDoctors,
        totalAppointments,
        totalBlogs
      },
      recentUsers,
      upcomingAppointments
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all users
router.get('/users', verifyAdmin, async (req, res) => {
  try {
    const users = await User.find()
      .select('-password')
      .sort({ createdAt: -1 });
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get user details
router.get('/users/:id', verifyAdmin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) return res.status(404).json({ error: 'User not found' });
    
    const userAppointments = await Appointment.find({ userId: req.params.id })
      .sort({ date: -1 });
    
    res.json({ user, appointments: userAppointments });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all appointments
router.get('/appointments', verifyAdmin, async (req, res) => {
  try {
    const appointments = await Appointment.find()
      .populate('userId', 'name email')
      .sort({ date: -1 });
    res.json(appointments);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Admin management (Master only)
router.get('/admins', verifyAdmin, verifyMasterAdmin, async (req, res) => {
  try {
    const admins = await Admin.find()
      .select('-password')
      .populate('createdBy', 'name email')
      .sort({ createdAt: -1 });
    res.json(admins);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create new admin (Master only)
router.post('/admins', verifyAdmin, verifyMasterAdmin, async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    
    if (!['master', 'admin'].includes(role)) {
      return res.status(400).json({ error: 'Invalid role' });
    }
    
    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ error: 'Admin already exists' });
    }
    
    const admin = new Admin({
      name,
      email,
      password,
      role,
      createdBy: req.admin.id
    });
    
    await admin.save();
    res.status(201).json({
      id: admin._id,
      name: admin.name,
      email: admin.email,
      role: admin.role,
      createdAt: admin.createdAt
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update admin (Master only)
router.put('/admins/:id', verifyAdmin, verifyMasterAdmin, async (req, res) => {
  try {
    const { name, email, role, isActive } = req.body;
    
    const admin = await Admin.findById(req.params.id);
    if (!admin) return res.status(404).json({ error: 'Admin not found' });
    
    // Prevent modifying own role
    if (admin._id.toString() === req.admin.id && role !== admin.role) {
      return res.status(400).json({ error: 'Cannot modify your own role' });
    }
    
    if (name) admin.name = name;
    if (email) admin.email = email;
    if (role) admin.role = role;
    if (typeof isActive === 'boolean') admin.isActive = isActive;
    
    await admin.save();
    res.json({
      id: admin._id,
      name: admin.name,
      email: admin.email,
      role: admin.role,
      isActive: admin.isActive
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete admin (Master only)
router.delete('/admins/:id', verifyAdmin, verifyMasterAdmin, async (req, res) => {
  try {
    const admin = await Admin.findById(req.params.id);
    if (!admin) return res.status(404).json({ error: 'Admin not found' });
    
    // Prevent deleting self
    if (admin._id.toString() === req.admin.id) {
      return res.status(400).json({ error: 'Cannot delete yourself' });
    }
    
    await Admin.findByIdAndDelete(req.params.id);
    res.json({ message: 'Admin deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
