const User = require('../models/User');

// @desc    Get user clusters
// @route   GET /api/users/clusters
// @access  Private
const getUserClusters = async (req, res) => {
  try {
    const { latitude, longitude, maxDistance = 5000, gridSize = 500 } = req.query;
    
    // Validate input
    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Please provide latitude and longitude' });
    }

    // Parse to numbers
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const distance = parseInt(maxDistance);
    const grid = parseInt(gridSize);

    if (isNaN(lat) || isNaN(lng) || isNaN(distance) || isNaN(grid)) {
      return res.status(400).json({ message: 'Invalid coordinates, distance, or grid size' });
    }

    // Create a geospatial query to find users within the specified radius
    // and aggregate them into clusters based on the grid size
    const clusters = await User.aggregate([
      // Find users within the specified radius
      {
        $geoNear: {
          near: {
            type: 'Point',
            coordinates: [lng, lat]
          },
          distanceField: 'distance',
          maxDistance: distance,
          spherical: true
        }
      },
      // Exclude the current user
      {
        $match: {
          _id: { $ne: req.user._id }
        }
      },
      // Project only the necessary fields
      {
        $project: {
          location: 1,
          distance: 1,
          // Calculate grid cell based on coordinates
          gridX: {
            $floor: {
              $divide: [
                { $subtract: [{ $arrayElemAt: ['$location.coordinates', 0] }, lng] },
                { $divide: [grid, 111320] } // Convert meters to degrees (approximate)
              ]
            }
          },
          gridY: {
            $floor: {
              $divide: [
                { $subtract: [{ $arrayElemAt: ['$location.coordinates', 1] }, lat] },
                { $divide: [grid, 111320] } // Convert meters to degrees (approximate)
              ]
            }
          }
        }
      },
      // Group by grid cell
      {
        $group: {
          _id: { gridX: '$gridX', gridY: '$gridY' },
          count: { $sum: 1 },
          avgLng: { $avg: { $arrayElemAt: ['$location.coordinates', 0] } },
          avgLat: { $avg: { $arrayElemAt: ['$location.coordinates', 1] } },
          avgDistance: { $avg: '$distance' }
        }
      },
      // Format the output
      {
        $project: {
          _id: 0,
          count: 1,
          coordinates: {
            type: 'Point',
            coordinates: ['$avgLng', '$avgLat']
          },
          distance: { $round: ['$avgDistance', 2] }
        }
      },
      // Sort by distance
      {
        $sort: { distance: 1 }
      }
    ]);

    res.status(200).json(clusters);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// @desc    Update user location
// @route   PUT /api/users/location
// @access  Private
const updateUserLocation = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    // Validate input
    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Please provide latitude and longitude' });
    }

    // Parse to numbers
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);

    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ message: 'Invalid coordinates' });
    }

    // Update user location
    const user = await User.findByIdAndUpdate(
      req.user._id,
      {
        location: {
          type: 'Point',
          coordinates: [lng, lat]
        }
      },
      { new: true }
    ).select('-password');

    res.status(200).json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getUserClusters,
  updateUserLocation
};
