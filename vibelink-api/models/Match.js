const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const MatchSchema = new Schema({
  // User who initiated the match (joined the moment)
  userId: { 
    type: Schema.Types.ObjectId, 
    ref: 'User',
    required: true
  },
  // User who created the moment
  creatorId: { 
    type: Schema.Types.ObjectId, 
    ref: 'User',
    required: true
  },
  // The moment that was joined
  momentId: { 
    type: Schema.Types.ObjectId, 
    ref: 'Moment',
    required: true
  },
  // Status of the match
  status: {
    type: String,
    enum: ['pending', 'accepted', 'rejected'],
    default: 'pending'
  },
  // Optional message sent when joining
  message: {
    type: String,
    trim: true,
    maxlength: 500
  },
  // Timestamps
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Create compound index to ensure a user can only join a moment once
MatchSchema.index({ userId: 1, momentId: 1 }, { unique: true });

module.exports = mongoose.model('Match', MatchSchema);
