const Match = require('../models/Match');
const Moment = require('../models/Moment');
const User = require('../models/User');

// @desc    Create a new match (join a moment)
// @route   POST /api/matches
// @access  Private
const createMatch = async (req, res) => {
  try {
    const { momentId, message } = req.body;

    // Validate input
    if (!momentId) {
      return res.status(400).json({ message: 'Please provide momentId' });
    }

    // Check if moment exists
    const moment = await Moment.findById(momentId);
    if (!moment) {
      return res.status(404).json({ message: 'Moment not found' });
    }

    // Prevent user from joining their own moment
    if (moment.userId.toString() === req.user._id.toString()) {
      return res.status(400).json({ message: 'You cannot join your own moment' });
    }

    // Check if match already exists
    const existingMatch = await Match.findOne({
      userId: req.user._id,
      momentId
    });

    if (existingMatch) {
      return res.status(400).json({ message: 'You have already joined this moment' });
    }

    // Create match
    const match = await Match.create({
      userId: req.user._id,
      creatorId: moment.userId,
      momentId,
      message: message || ''
    });

    // Populate user and moment info
    const populatedMatch = await Match.findById(match._id)
      .populate('userId', 'email')
      .populate('creatorId', 'email')
      .populate('momentId');

    res.status(201).json(populatedMatch);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Update match status (accept/reject)
// @route   PUT /api/matches/:id
// @access  Private
const updateMatchStatus = async (req, res) => {
  try {
    const { status } = req.body;

    // Validate input
    if (!status || !['accepted', 'rejected'].includes(status)) {
      return res.status(400).json({ message: 'Please provide valid status (accepted/rejected)' });
    }

    // Find match
    const match = await Match.findById(req.params.id);
    if (!match) {
      return res.status(404).json({ message: 'Match not found' });
    }

    // Check if user is the creator of the moment
    if (match.creatorId.toString() !== req.user._id.toString()) {
      return res.status(401).json({ message: 'Not authorized to update this match' });
    }

    // Update match status
    match.status = status;
    match.updatedAt = Date.now();
    await match.save();

    // Populate user and moment info
    const populatedMatch = await Match.findById(match._id)
      .populate('userId', 'email')
      .populate('creatorId', 'email')
      .populate('momentId');

    res.status(200).json(populatedMatch);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Get matches for current user (both as joiner and creator)
// @route   GET /api/matches
// @access  Private
const getMyMatches = async (req, res) => {
  try {
    // Get pagination parameters
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // Get matches where user is either the joiner or creator
    const matches = await Match.find({
      $or: [
        { userId: req.user._id },
        { creatorId: req.user._id }
      ]
    })
      .populate('userId', 'email')
      .populate('creatorId', 'email')
      .populate('momentId')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    // Count total matches for pagination
    const total = await Match.countDocuments({
      $or: [
        { userId: req.user._id },
        { creatorId: req.user._id }
      ]
    });

    res.status(200).json({
      matches,
      pagination: {
        total,
        page,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Get match by ID
// @route   GET /api/matches/:id
// @access  Private
const getMatchById = async (req, res) => {
  try {
    const match = await Match.findById(req.params.id)
      .populate('userId', 'email')
      .populate('creatorId', 'email')
      .populate('momentId');
    
    if (!match) {
      return res.status(404).json({ message: 'Match not found' });
    }

    // Check if user is part of the match
    if (match.userId.toString() !== req.user._id.toString() && 
        match.creatorId.toString() !== req.user._id.toString()) {
      return res.status(401).json({ message: 'Not authorized to view this match' });
    }

    res.status(200).json(match);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  createMatch,
  updateMatchStatus,
  getMyMatches,
  getMatchById
};
