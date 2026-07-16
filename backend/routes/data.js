const express = require('express');
const path = require('path');
const fs = require('fs');
const Blog = require('../models/Blog');
const router = express.Router();

function load(name) {
  return JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'data', `${name}.json`), 'utf8'));
}

router.get('/treatment-steps', (req, res) => res.json(load('treatmentSteps')));

router.get('/daily-tips', (req, res) => res.json(load('dailyTips')));

router.get('/faqs', (req, res) => res.json(load('faqs')));

router.get('/clinics', (req, res) => res.json(load('clinics')));

router.get('/categories', async (req, res) => {
  try {
    const categories = await Blog.distinct('category');
    res.json(categories.sort());
  } catch {
    res.json([]);
  }
});

module.exports = router;
