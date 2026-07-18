const Profile = require('../models/Profile');

const getAllProfiles = async (req, res) => {
  try {
    const { gender, religion, profession, age } = req.query;
    let query = { status: 'Active' };

    if (gender) {
      query.gender = gender;
    }
    if (religion && religion !== 'All') {
      query.religion = religion;
    }
    if (profession && profession !== 'All') {
      query.profession = { $regex: profession, $options: 'i' };
    }
    if (age && age !== 'All') {
      const parts = age.split('-');
      if (parts.length === 2) {
        query.age = { $gte: parseInt(parts[0]), $lte: parseInt(parts[1]) };
      }
    }

    const profiles = await Profile.find(query).sort({ id: 1 });
    res.status(200).json({ success: true, count: profiles.length, data: profiles });
  } catch (error) {
    console.error('Error fetching profiles:', error.message);
    res.status(500).json({ success: false, message: 'Server error fetching profiles' });
  }
};

const getProfileById = async (req, res) => {
  try {
    const profile = await Profile.findOne({ id: req.params.id });
    if (!profile) {
      return res.status(404).json({ success: false, message: 'Profile not found' });
    }
    res.status(200).json({ success: true, data: profile });
  } catch (error) {
    console.error('Error fetching profile:', error.message);
    res.status(500).json({ success: false, message: 'Server error fetching detailed profile' });
  }
};

module.exports = {
  getAllProfiles,
  getProfileById
};
