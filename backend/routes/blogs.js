const express = require('express');
const Blog = require('../models/Blog');
const User = require('../models/User');

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

router.get('/', async (req, res) => {
  try {
    const { search, category } = req.query;
    let filter = {};
    if (search) {
      const s = new RegExp(search, 'i');
      filter.$or = [{ title: s }, { excerpt: s }];
    }
    if (category) filter.category = category;
    const blogs = await Blog.find(filter).sort({ date: -1 });
    res.json(blogs);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const blog = await Blog.findById(req.params.id);
    if (!blog) return res.status(404).json({ error: 'Blog not found' });
    res.json(blog);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post('/:id/like', auth, async (req, res) => {
  try {
    const blog = await Blog.findById(req.params.id);
    if (!blog) return res.status(404).json({ error: 'Blog not found' });
    const user = await User.findById(req.user.id);
    const idx = (user.likedBlogs || []).indexOf(req.params.id);
    if (idx > -1) {
      user.likedBlogs.splice(idx, 1);
      blog.likes = Math.max(0, blog.likes - 1);
    } else {
      if (!user.likedBlogs) user.likedBlogs = [];
      user.likedBlogs.push(req.params.id);
      blog.likes += 1;
    }
    await user.save();
    await blog.save();
    res.json({ liked: idx === -1, likes: blog.likes, likedBlogs: user.likedBlogs });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.post('/:id/save', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    const idx = (user.savedBlogs || []).indexOf(req.params.id);
    if (idx > -1) {
      user.savedBlogs.splice(idx, 1);
    } else {
      if (!user.savedBlogs) user.savedBlogs = [];
      user.savedBlogs.push(req.params.id);
    }
    await user.save();
    res.json({ saved: idx === -1, savedBlogs: user.savedBlogs });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/user/preferences', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('likedBlogs savedBlogs');
    res.json({ likedBlogs: user.likedBlogs || [], savedBlogs: user.savedBlogs || [] });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
