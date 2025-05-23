# VibeLink API

Backend API for VibeLink - a Gen Z-focused dating app designed to spark real-world connections.

## Setup

1. Install dependencies:
```
npm install
```

2. Configure environment variables:
Create a `.env` file with the following variables:
```
PORT=3000
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
```

3. Run the server:
```
# Development mode with auto-restart
npm run dev

# Production mode
npm start
```

## API Endpoints

### Health Check
- GET `/api/health` - Check if the API is running

More endpoints coming soon as development progresses.
