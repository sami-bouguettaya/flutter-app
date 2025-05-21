const express = require('express');
const router = express.Router();
const Booking = require('../models/booking');
const Car = require('../models/car');
const { protect, admin } = require('../middleware/auth');

// @route   POST /api/bookings
// @desc    Créer une nouvelle réservation
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const { carId, startDate, endDate } = req.body;

    // Vérifier si la voiture existe
    const car = await Car.findById(carId);
    if (!car) {
      return res.status(404).json({ message: 'Voiture non trouvée' });
    }

    // Vérifier si la voiture est disponible pour ces dates
    const existingBooking = await Booking.findOne({
      car: carId,
      status: { $in: ['pending', 'confirmed'] },
      $or: [
        {
          startDate: { $lte: new Date(endDate) },
          endDate: { $gte: new Date(startDate) }
        }
      ]
    });

    if (existingBooking) {
      return res.status(400).json({ message: 'La voiture n\'est pas disponible pour ces dates' });
    }

    // Calculer le prix total
    const start = new Date(startDate);
    const end = new Date(endDate);
    const days = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    const totalPrice = days * car.pricePerDay;

    const booking = new Booking({
      car: carId,
      user: req.user._id,
      startDate,
      endDate,
      totalPrice,
      status: 'confirmed'
    });

    const newBooking = await booking.save();
    await newBooking.populate('car', 'brand model year pricePerDay');
    await newBooking.populate('user', 'nom email');

    res.status(201).json(newBooking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   GET /api/bookings
// @desc    Récupérer toutes les réservations de l'utilisateur
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.user._id })
      .populate('car', 'brand model year pricePerDay images')
      .populate('user', 'nom email')
      .sort({ createdAt: -1 });
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/bookings/:id
// @desc    Récupérer une réservation spécifique
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('car', 'brand model year pricePerDay images')
      .populate('user', 'nom email');
    
    if (!booking) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }

    // Vérifier si l'utilisateur est le propriétaire de la réservation
    if (booking.user._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Non autorisé' });
    }

    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/bookings/:id/cancel
// @desc    Annuler une réservation
// @access  Private
router.put('/:id/cancel', protect, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    
    if (!booking) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }

    // Vérifier si l'utilisateur est le propriétaire de la réservation
    if (booking.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Non autorisé' });
    }

    // Vérifier si la réservation peut être annulée
    if (booking.status !== 'pending' && booking.status !== 'confirmed') {
      return res.status(400).json({ message: 'Cette réservation ne peut pas être annulée' });
    }

    booking.status = 'cancelled';
    const updatedBooking = await booking.save();
    await updatedBooking.populate('car', 'brand model year pricePerDay');
    await updatedBooking.populate('user', 'nom email');

    res.json(updatedBooking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   GET /api/bookings/pending
// @desc    Récupérer toutes les réservations en attente (Admin)
// @access  Admin
router.get('/pending', protect, admin, async (req, res) => {
  try {
    const bookings = await Booking.find({ status: 'pending' })
      .populate('car', 'brand model year pricePerDay images')
      .populate('user', 'nom email');
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/bookings/:id/status
// @desc    Mettre à jour le statut d'une réservation (Admin)
// @access  Admin
router.put('/:id/status', protect, admin, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    
    if (!booking) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }

    const { status } = req.body;

    if (!['pending', 'confirmed', 'cancelled', 'completed'].includes(status)) {
        return res.status(400).json({ message: 'Statut invalide' });
    }

    booking.status = status;
    const updatedBooking = await booking.save();
    await updatedBooking.populate('car', 'brand model year pricePerDay images');
    await updatedBooking.populate('user', 'nom email');

    res.json(updatedBooking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router; 