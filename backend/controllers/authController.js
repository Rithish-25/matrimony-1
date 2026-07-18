const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/User');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'soulmate_secret_key_2026', {
    expiresIn: '30d'
  });
};

const signup = async (req, res) => {
  try {
    const { fullName, email, mobile, password, role } = req.body;

    if (!fullName || !mobile || !password) {
      return res.status(400).json({ success: false, message: 'Please provide name, mobile, and password' });
    }

    if (email) {
      const emailExists = await User.findOne({ email });
      if (emailExists) {
        return res.status(400).json({ success: false, message: 'Email already registered' });
      }
    }

    const mobileExists = await User.findOne({ mobile });
    if (mobileExists) {
      return res.status(400).json({ success: false, message: 'Mobile number already registered' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Dynamic role mapping with safety fallbacks
    const finalRole = (role === 'Admin' || fullName.toLowerCase() === 'admin' || (email && email.toLowerCase() === 'admin@soulmate.com')) ? 'Admin' : 'User';

    const user = await User.create({
      fullName,
      ...(email && email.trim() !== '' ? { email } : {}),
      mobile,
      password: hashedPassword,
      authProvider: 'local',
      role: finalRole
    });

    res.status(201).json({
      success: true,
      token: generateToken(user._id),
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        mobile: user.mobile,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Signup error:', error.message);
    res.status(500).json({ success: false, message: 'Server error during registration' });
  }
};

const login = async (req, res) => {
  try {
    const { emailOrPhone, password } = req.body;

    if (!emailOrPhone || !password) {
      return res.status(400).json({ success: false, message: 'Please provide credentials' });
    }

    // Search by email or mobile
    const user = await User.findOne({
      $or: [{ email: emailOrPhone.toLowerCase() }, { mobile: emailOrPhone }]
    });

    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    if (user.authProvider !== 'local') {
      return res.status(400).json({ success: false, message: `Please log in using your ${user.authProvider} account` });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    res.status(200).json({
      success: true,
      token: generateToken(user._id),
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        mobile: user.mobile,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Login error:', error.message);
    res.status(500).json({ success: false, message: 'Server error during login' });
  }
};

const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.status(200).json({ success: true, user });
  } catch (error) {
    console.error('Get profile error:', error.message);
    res.status(500).json({ success: false, message: 'Server error fetching user profile' });
  }
};

module.exports = {
  signup,
  login,
  getProfile
};
