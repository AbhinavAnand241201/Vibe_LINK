const express = require('express');
const router = express.Router();
const { createMoment, getNearbyMoments, getMomentById, deleteMoment } = require('../controllers/momentController');
const { protect } = require('../middleware/authMiddleware');

// All routes are protected with auth middleware
router.use(protect);

// Create a new moment
router.post('/', createMoment);

// Get nearby moments
router.get('/nearby', getNearbyMoments);

// Get moment by ID
router.get('/:id', getMomentById);

// Delete moment
router.delete('/:id', deleteMoment);

module.exports = router;
