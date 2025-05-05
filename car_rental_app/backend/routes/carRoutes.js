const express = require('express');
const router = express.Router();
const Car = require('../models/Car');

// @route   GET /api/cars
// @desc    Get all cars
router.get('/', async (req, res) => {
  try {
    const cars = await Car.find().populate('owner', 'name email');
    res.json(cars);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/cars
// @desc    Create a car
router.post('/', async (req, res) => {
  const car = new Car(req.body);
  try {
    const newCar = await car.save();
    res.status(201).json(newCar);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   GET /api/cars/:id
// @desc    Get car by ID
router.get('/:id', async (req, res) => {
  try {
    const car = await Car.findById(req.params.id).populate('owner', 'name email');
    if (!car) {
      return res.status(404).json({ message: 'Car not found' });
    }
    res.json(car);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/cars/:id
// @desc    Update a car
router.put('/:id', async (req, res) => {
  try {
    const car = await Car.findById(req.params.id);
    if (!car) {
      return res.status(404).json({ message: 'Car not found' });
    }
    Object.assign(car, req.body);
    const updatedCar = await car.save();
    res.json(updatedCar);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// @route   DELETE /api/cars/:id
// @desc    Delete a car
router.delete('/:id', async (req, res) => {
  try {
    const car = await Car.findById(req.params.id);
    if (!car) {
      return res.status(404).json({ message: 'Car not found' });
    }
    await car.remove();
    res.json({ message: 'Car deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router; 