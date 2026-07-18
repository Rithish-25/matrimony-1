const express = require('express');
const { getDashboardStats, createProfile, updateProfile, deleteProfile, uploadImages, uploadMiddleware } = require('../controllers/adminController');
const { protect, admin } = require('../middleware/authMiddleware');

const router = express.Router();

// Route checks: Protect routes for authenticated admin-role sessions
router.use(protect);
router.use(admin);

router.get('/dashboard', getDashboardStats);
router.post('/profile', createProfile);
router.put('/profile/:id', updateProfile);
router.delete('/profile/:id', deleteProfile);
router.post('/upload', uploadMiddleware, uploadImages);

module.exports = router;
