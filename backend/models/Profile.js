const mongoose = require('mongoose');

const profileSchema = new mongoose.Schema({
  id: {
    type: Number,
    required: true,
    unique: true
  },
  name: {
    type: String,
    required: true
  },
  photoUrl: {
    type: String,
    required: true
  },
  gender: {
    type: String,
    required: true
  },
  age: {
    type: Number,
    required: true
  },
  height: {
    type: String,
    required: true
  },
  weight: {
    type: String,
    default: ''
  },
  religion: {
    type: String,
    required: true
  },
  caste: {
    type: String,
    required: true
  },
  motherTongue: {
    type: String,
    default: 'English'
  },
  education: {
    type: String,
    required: true
  },
  profession: {
    type: String,
    required: true
  },
  salary: {
    type: String,
    required: true
  },
  city: {
    type: String,
    required: true
  },
  state: {
    type: String,
    required: true
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  compatibilityScore: {
    type: Number,
    default: 80
  },
  maritalStatus: {
    type: String,
    default: 'Single'
  },
  about: {
    type: String,
    default: ''
  },
  contactNumber: {
    type: String,
    default: ''
  },
  email: {
    type: String,
    default: ''
  },
  status: {
    type: String,
    enum: ['Active', 'Inactive'],
    default: 'Active'
  },
  // Horoscope Details
  star: { type: String, default: '' },
  rasi: { type: String, default: '' },
  lagna: { type: String, default: '' },
  dosham: { type: String, default: '' },
  birthDate: { type: String, default: '' },
  birthTime: { type: String, default: '' },
  birthPlace: { type: String, default: '' },
  gothram: { type: String, default: '' },
  moonSign: { type: String, default: '' },
  sunSign: { type: String, default: '' },
  dasaBalance: { type: String, default: '' },
  chevvaiDosham: { type: String, default: '' },
  nadi: { type: String, default: '' },
  ganam: { type: String, default: '' },
  yoni: { type: String, default: '' },
  rajju: { type: String, default: '' },
  mahendraPorutham: { type: String, default: '' },
  dinaPorutham: { type: String, default: '' },
  rasiPorutham: { type: String, default: '' },
  overallCompatibility: { type: String, default: '' },

  // Family Details
  fatherOccupation: { type: String, default: '' },
  motherOccupation: { type: String, default: '' },
  siblings: { type: String, default: '' },
  familyType: { type: String, default: '' },
  familyStatus: { type: String, default: '' },

  // Lifestyle
  foodPreference: { type: String, default: '' },
  smoking: { type: String, default: '' },
  drinking: { type: String, default: '' },
  hobbies: { type: [String], default: [] },
  languagesKnown: { type: [String], default: [] },
  
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Profile', profileSchema);
