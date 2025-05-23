const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const MomentSchema = new Schema({
  userId: { 
    type: Schema.Types.ObjectId, 
    ref: 'User',
    required: true
  },
  caption: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200
  },
  mediaURL: {
    type: String,
    required: true
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      required: true
    }
  },
  expiresAt: {
    type: Date,
    required: true,
    default: function() {
      // Default expiration is 24 hours from now
      const now = new Date();
      return new Date(now.getTime() + 24 * 60 * 60 * 1000);
    }
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Create 2dsphere index for geospatial queries
MomentSchema.index({ location: '2dsphere' });
// Create TTL index for automatic expiration
MomentSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model('Moment', MomentSchema);
