const express = require('express');
const router = express.Router();
const { getUserClusters, updateUserLocation } = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

// All routes are protected with auth middleware
router.use(protect);

// Get user clusters
router.get('/clusters', getUserClusters);

// Update user location
router.put('/location', updateUserLocation);

module.exports = router;
