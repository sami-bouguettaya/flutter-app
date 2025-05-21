const express = require('express');
const router = express.Router();
const User = require('../models/user');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { protect, admin } = require('../middleware/auth');

// @route   POST /api/users/register
// @desc    Register a new user
router.post('/register', async (req, res) => {
  try {
    console.log('Données reçues pour inscription:', req.body);
    // Récupère les données en utilisant uniquement les champs français
    let nom = req.body.nom;
    const email = req.body.email;
    let password = req.body.password;
    let telephone = req.body.telephone;
    let adresse = req.body.adresse;

    // Si nom est vide ou absent, on met une valeur par défaut
    if (!nom || typeof nom !== 'string' || nom.trim() === "") {
      nom = "Utilisateur";
    }

    // Vérification des champs obligatoires (en français)
    if (!email || !password || !telephone || !adresse) {
      return res.status(400).json({ message: 'Tous les champs obligatoires (nom, email, password, telephone, adresse) doivent être présents et non vides.' });
    }

    // Vérification que le mot de passe n'est pas vide
    if (typeof password !== 'string' || password.trim() === "") {
      return res.status(400).json({ message: 'Le mot de passe est obligatoire.' });
    }

    // Vérification que le telephone n'est pas vide
    if (typeof telephone !== 'string' || telephone.trim() === "") {
      return res.status(400).json({ message: 'Le téléphone est obligatoire.' });
    }

    // Vérification que l'adresse n'est pas vide
    if (typeof adresse !== 'string' || adresse.trim() === "") {
      return res.status(400).json({ message: 'L\'adresse est obligatoire.' });
    }

    // Check if user already exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'Un utilisateur avec cet email existe déjà.' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = new User({
      nom,
      email,
      password,
      telephone,
      adresse,
      role: 'user'
    });

    const savedUser = await user.save();

    // Generate JWT token
    const token = jwt.sign(
      { id: savedUser._id },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '30d' }
    );

    res.status(201).json({
      _id: savedUser._id,
      nom: savedUser.nom,
      email: savedUser.email,
      telephone: savedUser.telephone,
      adresse: savedUser.adresse,
      role: savedUser.role,
      token
    });
  } catch (error) {
    console.error('Erreur lors de l\'inscription:', error);
    res.status(400).json({ message: error.message });
  }
});

// @route   POST /api/users/login
// @desc    Login user
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '30d' }
    );

    res.json({
      _id: user._id,
      nom: user.nom,
      email: user.email,
      telephone: user.telephone,
      adresse: user.adresse,
      role: user.role,
      token
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   GET /api/users/profile
// @desc    Get user profile
router.get('/profile', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({
      _id: user._id,
      nom: user.nom,
      email: user.email,
      telephone: user.telephone,
      adresse: user.adresse,
      role: user.role
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/users/favorites/:carId
// @desc    Ajouter une voiture aux favoris de l'utilisateur
// @access  Private
router.post('/favorites/:carId', protect, async (req, res) => {
  try {
    console.log('Received request to add favorite for car ID:', req.params.carId);
    console.log('Authenticated user:', req.user._id);
    const user = await User.findById(req.user._id);
    const carId = req.params.carId;

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    // Check if car is already in favorites
    if (user.favorites.includes(carId)) {
      return res.status(400).json({ message: 'Voiture déjà dans les favoris' });
    }

    user.favorites.push(carId);
    await user.save();
    // Populate favorites to return updated list with car details
    await user.populate('favorites', 'brand model year pricePerDay images');
    res.json(user.favorites);

  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   DELETE /api/users/favorites/:carId
// @desc    Retirer une voiture des favoris de l'utilisateur
// @access  Private
router.delete('/favorites/:carId', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const carId = req.params.carId;

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    // Check if car is in favorites
    if (!user.favorites.includes(carId)) {
      return res.status(400).json({ message: 'Voiture non trouvée dans les favoris' });
    }

    user.favorites = user.favorites.filter(favCarId => favCarId.toString() !== carId);
    await user.save();
     // Populate favorites to return updated list with car details
    await user.populate('favorites', 'brand model year pricePerDay images');
    res.json(user.favorites);

  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   GET /api/users/favorites
// @desc    Récupérer les voitures favorites de l'utilisateur
// @access  Private
router.get('/favorites', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate('favorites', 'brand model year pricePerDay images');

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    res.json(user.favorites);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router; 