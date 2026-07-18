const Profile = require('../models/Profile');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Multer Local Upload Storage Setup
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(__dirname, '../uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueName + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

const getDashboardStats = async (req, res) => {
  try {
    const total = await Profile.countDocuments();
    const active = await Profile.countDocuments({ status: 'Active' });
    const inactive = await Profile.countDocuments({ status: 'Inactive' });

    res.status(200).json({
      success: true,
      data: {
        totalProfiles: total,
        activeProfiles: active,
        inactiveProfiles: inactive
      }
    });
  } catch (error) {
    console.error('Error fetching admin stats:', error.message);
    res.status(500).json({ success: false, message: 'Server error fetching dashboard statistics' });
  }
};

const createProfile = async (req, res) => {
  try {
    // Generate auto-increment ID
    const lastProfile = await Profile.findOne().sort({ id: -1 });
    const nextId = lastProfile ? lastProfile.id + 1 : 1;

    const profileData = { ...req.body, id: nextId };
    const profile = await Profile.create(profileData);

    res.status(201).json({
      success: true,
      message: 'Profile created successfully',
      data: profile
    });
  } catch (error) {
    console.error('Error creating profile:', error.message);
    res.status(500).json({ success: false, message: 'Server error creating profile entry' });
  }
};

const updateProfile = async (req, res) => {
  try {
    const profile = await Profile.findOneAndUpdate(
      { id: req.params.id },
      req.body,
      { new: true, runValidators: true }
    );

    if (!profile) {
      return res.status(404).json({ success: false, message: 'Profile not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: profile
    });
  } catch (error) {
    console.error('Error updating profile:', error.message);
    res.status(500).json({ success: false, message: 'Server error updating profile entry' });
  }
};

const deleteProfile = async (req, res) => {
  try {
    const profile = await Profile.findOneAndDelete({ id: req.params.id });

    if (!profile) {
      return res.status(404).json({ success: false, message: 'Profile not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Profile deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting profile:', error.message);
    res.status(500).json({ success: false, message: 'Server error deleting profile entry' });
  }
};

const uploadImages = (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, message: 'No files uploaded' });
    }

    const urls = req.files.map(file => {
      return `${req.protocol}://${req.get('host')}/uploads/${file.filename}`;
    });

    res.status(200).json({
      success: true,
      message: 'Images uploaded successfully',
      urls
    });
  } catch (error) {
    console.error('Image upload controller error:', error.message);
    res.status(500).json({ success: false, message: 'Server error uploading files' });
  }
};

module.exports = {
  getDashboardStats,
  createProfile,
  updateProfile,
  deleteProfile,
  uploadImages,
  uploadMiddleware: upload.array('images', 5) // max 5 files
};
