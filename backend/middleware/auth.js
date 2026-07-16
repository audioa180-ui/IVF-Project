const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'bloom_ivf_jwt_secret_dev';

function authenticate(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Authentication token is required' });
  }
  try {
    req.user = jwt.verify(header.substring(7), JWT_SECRET);
    next();
  } catch (_) {
    return res.status(401).json({ error: 'Your session has expired. Please sign in again.' });
  }
}

function requireAdmin(req, res, next) {
  authenticate(req, res, () => {
    if (!req.user.role || !['admin', 'master'].includes(req.user.role)) {
      return res.status(403).json({ error: 'Administrator access is required' });
    }
    next();
  });
}

module.exports = { authenticate, requireAdmin };
