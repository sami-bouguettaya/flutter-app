const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  nom: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  telephone: {
    type: String,
    required: true
  },
  adresse: {
    type: String,
    required: true
  },
  favorites: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Car',
    }
  ],
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  isAdmin: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Method to compare password
userSchema.methods.matchPassword = async function(enteredPassword) {
  return enteredPassword === this.password;
};

module.exports = mongoose.model('User', userSchema); 