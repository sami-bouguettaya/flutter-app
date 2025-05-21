const express = require('express');
const router = express.Router();
const Car = require('../models/car');
const { protect, admin } = require('../middleware/auth');
const Booking = require('../models/booking');

// @route   GET /api/cars
// @desc    Récupérer toutes les voitures approuvées (avec filtrage et recherche)
// @access  Public
router.get('/', async (req, res) => {
  try {
    const { brand, model, location, minPrice, maxPrice, search, category } = req.query;
    const query = { status: 'approved' };

    if (brand) {
      query.brand = brand;
    }
    if (model) {
      query.model = model;
    }
    if (location) {
      query.location = location;
    }
    if (category) {
      query.category = category;
    }
    if (minPrice) {
      query.pricePerDay = { ...query.pricePerDay, $gte: parseFloat(minPrice) };
    }
    if (maxPrice) {
      query.pricePerDay = { ...query.pricePerDay, $lte: parseFloat(maxPrice) };
    }

    // Recherche plein texte (simple, peut être améliorée avec index texte MongoDB)
    if (search) {
      query.$or = [
        { brand: { $regex: search, $options: 'i' } },
        { model: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { location: { $regex: search, $options: 'i' } },
      ];
    }

    const cars = await Car.find(query)
      .populate('owner', 'nom email telephone')
      .populate('ratings.user', 'username');

    // Calculate and add average rating to each car object
    const carsWithAverageRating = cars.map(car => {
      // Convert Mongoose document to a plain JavaScript object
      const carObject = car.toObject(); 
      carObject.rating = car.getAverageRating(); // Add the calculated average rating
      return carObject;
    });

    res.json(carsWithAverageRating); // Send the modified array
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/cars/pending
// @desc    Récupérer les voitures en attente d'approbation
// @access  Admin
router.get('/pending', protect, admin, async (req, res) => {
  try {
    const cars = await Car.find({ status: 'pending' })
      .populate('owner', 'username email');
    res.json(cars);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/cars/rejected
// @desc    Récupérer les voitures rejetées
// @access  Admin
router.get('/rejected', protect, admin, async (req, res) => {
  try {
    const cars = await Car.find({ status: 'rejected' })
      .populate('owner', 'username email');
    res.json(cars);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/cars
// @desc    Créer une nouvelle voiture
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const car = new Car({
      ...req.body,
      owner: req.user._id,
      status: 'pending'
    });
    const newCar = await car.save();
    res.status(201).json(newCar);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   PUT /api/cars/:id/approve
// @desc    Approuver une voiture
// @access  Admin
router.put('/:id/approve', protect, admin, async (req, res) => {
  try {
    const car = await Car.findById(req.params.id);
    if (!car) {
      return res.status(404).json({ message: 'Voiture non trouvée' });
    }
    car.status = 'approved';
    const updatedCar = await car.save();
    res.json(updatedCar);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   PUT /api/cars/:id/reject
// @desc    Rejeter une voiture
// @access  Admin
router.put('/:id/reject', protect, admin, async (req, res) => {
  try {
    const car = await Car.findById(req.params.id);
    if (!car) {
      return res.status(404).json({ message: 'Voiture non trouvée' });
    }
    car.status = 'rejected';
    const updatedCar = await car.save();
    res.json(updatedCar);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   DELETE /api/cars/:id
// @desc    Supprimer une voiture
// @access  Admin
router.delete('/:id', protect, admin, async (req, res) => {
  try {
    const car = await Car.findById(req.params.id);
    if (!car) {
      return res.status(404).json({ message: 'Voiture non trouvée' });
    }
    await car.remove();
    res.json({ message: 'Voiture supprimée' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/cars/:id/check-availability
// @desc    Vérifier la disponibilité d'une voiture pour une période donnée
// @access  Private
router.post('/:id/check-availability', protect, async (req, res) => {
  try {
    const { startDate, endDate } = req.body;
    const carId = req.params.id;

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

    res.json({ available: !existingBooking });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   POST /api/cars/:id/ratings
// @desc    Soumettre une note et un commentaire pour une voiture
// @access  Private
router.post('/:id/ratings', protect, async (req, res) => {
  try {
    const carId = req.params.id;
    const { rating, comment } = req.body;

    if (!rating || typeof rating !== 'number' || rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'La note doit être un nombre entre 1 et 5.' });
    }

    const car = await Car.findById(carId);

    if (!car) {
      return res.status(404).json({ message: 'Voiture non trouvée.' });
    }

    // Check if the user has already rated this car
    const existingRatingIndex = car.ratings.findIndex(
      (r) => r.user.toString() === req.user._id.toString()
    );

    if (existingRatingIndex > -1) {
      // Update existing rating
      car.ratings[existingRatingIndex].rating = rating;
      car.ratings[existingRatingIndex].comment = comment;
      car.ratings[existingRatingIndex].createdAt = Date.now(); // Update timestamp
    } else {
      // Add new rating
      car.ratings.push({
        user: req.user._id,
        rating: rating,
        comment: comment,
      });
    }

    await car.save();

    // Populate the user for the new/updated rating before sending response
     await car.populate('ratings.user', 'username'); // Assuming user's name is 'username' in ratings population

    res.status(201).json({
      message: 'Note soumise avec succès.',
      carId: car._id,
      averageRating: car.getAverageRating(), // Assuming getAverageRating is a method on your Car model
      ratings: car.ratings, // Return updated ratings list
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router; 