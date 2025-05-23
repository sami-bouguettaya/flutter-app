const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/user');
const Car = require('../models/car');

// Connexion à MongoDB
mongoose.connect('mongodb://localhost:27017/car_rental_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

const seedDatabase = async () => {
  try {
    // Supprimer les données existantes
    await User.deleteMany({});
    await Car.deleteMany({});

    // Créer l'utilisateur admin
    const admin = await User.create({
      nom: 'Administrateur',
      email: 'admin@admin.com',
      password: await bcrypt.hash('admin', 10),
      telephone: '0000000000',
      adresse: '123 Rue Admin',
      role: 'admin'
    });

    // Créer des utilisateurs de test
    const users = await User.create([
      {
        nom: 'John Doe',
        email: 'john@example.com',
        password: await bcrypt.hash('password123', 10),
        telephone: '1234567890',
        adresse: '456 Rue Example',
        role: 'user'
      },
      {
        nom: 'Jane Smith',
        email: 'jane@example.com',
        password: await bcrypt.hash('password123', 10),
        telephone: '0987654321',
        adresse: '789 Rue Test',
        role: 'user'
      },
      {
        nom: 'Bob Wilson',
        email: 'bob@example.com',
        password: await bcrypt.hash('password123', 10),
        telephone: '5555555555',
        adresse: '321 Rue Sample',
        role: 'user'
      }
    ]);

    // Créer des voitures de test
    await Car.create([
      {
        brand: 'Toyota',
        model: 'Corolla',
        year: 2020,
        pricePerDay: 50,
        description: 'Voiture économique et fiable',
        location: 'Paris',
        image: 'https://example.com/toyota-corolla.jpg',
        owner: users[0]._id,
        available: true,
        status: 'approved',
        features: ['Climatisation', 'GPS', 'Bluetooth'],
        ratings: [
          { user: users[1]._id, rating: 4, comment: 'Très bon état' },
          { user: users[2]._id, rating: 5, comment: 'Excellent service' }
        ]
      },
      {
        brand: 'BMW',
        model: 'Série 3',
        year: 2021,
        pricePerDay: 80,
        description: 'Luxe et performance',
        location: 'Lyon',
        image: 'https://example.com/bmw-serie3.jpg',
        owner: users[1]._id,
        available: true,
        status: 'pending',
        features: ['Climatisation', 'GPS', 'Bluetooth', 'Caméra de recul'],
        ratings: [
          { user: users[0]._id, rating: 5, comment: 'Superbe voiture' }
        ]
      },
      {
        brand: 'Renault',
        model: 'Clio',
        year: 2019,
        pricePerDay: 40,
        description: 'Citadine pratique',
        location: 'Marseille',
        image: 'https://example.com/renault-clio.jpg',
        owner: users[2]._id,
        available: true,
        status: 'rejected',
        features: ['Climatisation', 'Bluetooth'],
        ratings: []
      }
    ]);

    console.log('Base de données initialisée avec succès !');
    process.exit(0);
  } catch (error) {
    console.error('Erreur lors de l\'initialisation de la base de données:', error);
    process.exit(1);
  }
};

seedDatabase(); 