const Moment = require('../models/Moment');
const User = require('../models/User');

// @desc    Create a new moment
// @route   POST /api/moments
// @access  Private
const createMoment = async (req, res) => {
  try {
    const { caption, mediaURL, latitude, longitude } = req.body;

    // Validate input
    if (!caption || !mediaURL || !latitude || !longitude) {
      return res.status(400).json({ message: 'Please provide caption, mediaURL, latitude, and longitude' });
    }

    // Create moment
    const moment = await Moment.create({
      userId: req.user._id,
      caption,
      mediaURL,
      location: {
        type: 'Point',
        coordinates: [longitude, latitude] // GeoJSON format is [longitude, latitude]
      }
    });

    res.status(201).json(moment);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Get nearby moments
// @route   GET /api/moments/nearby
// @access  Private
const getNearbyMoments = async (req, res) => {
  try {
    const { latitude, longitude, maxDistance = 5000 } = req.query; // maxDistance in meters (default 5km)
    
    // Validate input
    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Please provide latitude and longitude' });
    }

    // Parse to numbers
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const distance = parseInt(maxDistance);

    if (isNaN(lat) || isNaN(lng) || isNaN(distance)) {
      return res.status(400).json({ message: 'Invalid coordinates or distance' });
    }

    // Get pagination parameters
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // Find moments within the specified radius
    const moments = await Moment.find({
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [lng, lat]
          },
          $maxDistance: distance
        }
      }
    })
    .populate('userId', 'email') // Populate user info (excluding password)
    .sort({ createdAt: -1 }) // Sort by most recent
    .skip(skip)
    .limit(limit);

    // Count total moments for pagination
    const total = await Moment.countDocuments({
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [lng, lat]
          },
          $maxDistance: distance
        }
      }
    });

    res.status(200).json({
      moments,
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

// @desc    Get moment by ID
// @route   GET /api/moments/:id
// @access  Private
const getMomentById = async (req, res) => {
  try {
    const moment = await Moment.findById(req.params.id).populate('userId', 'email');
    
    if (!moment) {
      return res.status(404).json({ message: 'Moment not found' });
    }

    res.status(200).json(moment);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Delete moment
// @route   DELETE /api/moments/:id
// @access  Private
const deleteMoment = async (req, res) => {
  try {
    const moment = await Moment.findById(req.params.id);
    
    if (!moment) {
      return res.status(404).json({ message: 'Moment not found' });
    }

    // Check if user owns the moment
    if (moment.userId.toString() !== req.user._id.toString()) {
      return res.status(401).json({ message: 'Not authorized to delete this moment' });
    }

    await moment.deleteOne();
    res.status(200).json({ message: 'Moment deleted' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  createMoment,
  getNearbyMoments,
  getMomentById,
  deleteMoment
};
