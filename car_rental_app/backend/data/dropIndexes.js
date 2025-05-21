const mongoose = require('mongoose');

// Connexion à MongoDB
mongoose.connect('mongodb://localhost:27017/car_rental_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(async () => {
  try {
    const db = mongoose.connection.db;
    await db.collection('users').dropIndexes();
    console.log('Indexes supprimés avec succès !');
    process.exit(0);
  } catch (error) {
    console.error('Erreur lors de la suppression des index:', error);
    process.exit(1);
  }
}).catch(error => {
  console.error('Erreur de connexion à MongoDB:', error);
  process.exit(1);
}); 