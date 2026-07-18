const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  fullName: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: false,
    unique: true,
    sparse: true,
    trim: true,
    lowercase: true
  },
  mobile: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  password: {
    type: String,
    required: function() {
      // Password is only required for local auth provider logins
      return this.authProvider === 'local';
    }
  },
  role: {
    type: String,
    enum: ['User', 'Admin'],
    default: 'User'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('User', userSchema);
