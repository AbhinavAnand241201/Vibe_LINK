const express = require('express');
const router = express.Router();
const { createMatch, updateMatchStatus, getMyMatches, getMatchById } = require('../controllers/matchController');
const { protect } = require('../middleware/authMiddleware');

// All routes are protected with auth middleware
router.use(protect);

// Create a new match (join a moment)
router.post('/', createMatch);

// Update match status (accept/reject)
router.put('/:id', updateMatchStatus);

// Get matches for current user
router.get('/', getMyMatches);

// Get match by ID
router.get('/:id', getMatchById);

module.exports = router;
