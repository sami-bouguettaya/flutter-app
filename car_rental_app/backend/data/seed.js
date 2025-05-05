const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Car = require('../models/Car');

const seedDatabase = async () => {
  try {
    // Connexion à la base de données
    await mongoose.connect('mongodb://localhost:27017/car_rental_db', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    // Suppression des données existantes
    await User.deleteMany({});
    await Car.deleteMany({});

    // Création des utilisateurs
    const users = [
      {
        name: 'John Doe',
        email: 'john@example.com',
        password: await bcrypt.hash('password123', 10),
        phone: '1234567890',
        address: '123 Main St, Paris',
        isAdmin: true,
      },
      {
        name: 'Jane Smith',
        email: 'jane@example.com',
        password: await bcrypt.hash('password123', 10),
        phone: '0987654321',
        address: '456 Oak St, Lyon',
        isAdmin: false,
      },
      {
        name: 'Bob Johnson',
        email: 'bob@example.com',
        password: await bcrypt.hash('password123', 10),
        phone: '1122334455',
        address: '789 Pine St, Marseille',
        isAdmin: false,
      },
    ];

    const createdUsers = await User.insertMany(users);

    // Création des voitures
    const cars = [
      {
        brand: 'Toyota',
        model: 'Corolla',
        year: 2022,
        pricePerDay: 50,
        image: 'https://example.com/toyota-corolla.jpg',
        available: true,
        description: 'Voiture familiale confortable et économique',
        location: 'Paris',
        owner: createdUsers[0]._id,
      },
      {
        brand: 'BMW',
        model: 'X5',
        year: 2021,
        pricePerDay: 120,
        image: 'https://example.com/bmw-x5.jpg',
        available: true,
        description: 'SUV luxueux avec toutes les options',
        location: 'Lyon',
        owner: createdUsers[1]._id,
      },
      {
        brand: 'Renault',
        model: 'Clio',
        year: 2023,
        pricePerDay: 40,
        image: 'https://example.com/renault-clio.jpg',
        available: true,
        description: 'Voiture citadine idéale pour la ville',
        location: 'Marseille',
        owner: createdUsers[2]._id,
      },
      {
        brand: 'Mercedes',
        model: 'C-Class',
        year: 2022,
        pricePerDay: 100,
        image: 'https://example.com/mercedes-c-class.jpg',
        available: true,
        description: 'Berline premium avec intérieur en cuir',
        location: 'Paris',
        owner: createdUsers[0]._id,
      },
      {
        brand: 'Peugeot',
        model: '208',
        year: 2023,
        pricePerDay: 45,
        image: 'https://example.com/peugeot-208.jpg',
        available: true,
        description: 'Voiture compacte avec design moderne',
        location: 'Lyon',
        owner: createdUsers[1]._id,
      },
    ];

    await Car.insertMany(cars);

    console.log('Base de données remplie avec succès !');
    process.exit(0);
  } catch (error) {
    console.error('Erreur lors du remplissage de la base de données:', error);
    process.exit(1);
  }
};

seedDatabase(); 