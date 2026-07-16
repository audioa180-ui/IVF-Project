const mongoose = require('mongoose');
const Admin = require('./models/Admin');
require('dotenv').config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb+srv://audioa180_db_user:9ToNBulgSMJwrs9U@cluster0.vc3reag.mongodb.net/bloom_ivf?retryWrites=true&w=majority';

async function seedAdmin() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('Connected to MongoDB');

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({ email: 'admin@bloomivf.com' });
    if (existingAdmin) {
      console.log('Admin user already exists');
      process.exit(0);
    }

    // Create master admin
    const admin = await Admin.create({
      name: 'Master Admin',
      email: 'admin@bloomivf.com',
      password: 'admin123',
      role: 'master',
      isActive: true
    });

    console.log('Master admin created successfully:');
    console.log('Email: admin@bloomivf.com');
    console.log('Password: admin123');
    console.log('Role: master');
    
    process.exit(0);
  } catch (error) {
    console.error('Error seeding admin:', error);
    process.exit(1);
  }
}

seedAdmin();
