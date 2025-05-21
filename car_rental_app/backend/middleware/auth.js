const jwt = require('jsonwebtoken');
const User = require('../models/user');

// Middleware pour protéger les routes
const protect = async (req, res, next) => {
  console.log('Protect middleware triggered.');
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      // Récupérer le token
      token = req.headers.authorization.split(' ')[1];
      console.log('Token extracted:', token ? 'exists' : 'missing');

      // Vérifier le token
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
      console.log('Token verified. Decoded user ID:', decoded.id);

      // Récupérer l'utilisateur
      req.user = await User.findById(decoded.id).select('-password');
      console.log('User found:', req.user ? req.user._id : 'none');

      console.log('Protect middleware calling next().');
      next();
    } catch (error) {
      console.error('Protect middleware error:', error.message);
      res.status(401).json({ message: 'Non autorisé, token invalide' });
    }
  }

  if (!token) {
    console.log('No token provided in headers.');
    res.status(401).json({ message: 'Non autorisé, pas de token' });
  } else if (res.headersSent) { // Prevent sending headers twice if an error occurred
    console.log('Headers already sent, not sending no token error.');
  }
};

// Middleware pour vérifier le rôle admin
const admin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    res.status(403).json({ message: 'Accès refusé, rôle admin requis' });
  }
};

module.exports = { protect, admin }; 