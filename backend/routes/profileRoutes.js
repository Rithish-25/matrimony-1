const express = require('express');
const { getAllProfiles, getProfileById } = require('../controllers/profileController');

const router = express.Router();

router.get('/', getAllProfiles);
router.get('/:id', getProfileById);

module.exports = router;
