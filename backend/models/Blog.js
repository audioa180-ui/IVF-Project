const mongoose = require('mongoose');

const blogSchema = new mongoose.Schema({
  title: { type: String, required: true },
  excerpt: { type: String, default: '' },
  content: { type: String, default: '' },
  category: { type: String, default: '' },
  readTime: { type: Number, default: 5 },
  likes: { type: Number, default: 0 },
  image: { type: String, default: '' },
  author: { type: String, default: '' },
  date: { type: Date, default: Date.now },
}, { timestamps: true });

module.exports = mongoose.model('Blog', blogSchema);
