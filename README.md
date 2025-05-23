# Vibe_LINK

## 🚀 Overview

Vibe_LINK is a next-generation dating application designed specifically for Gen Z users, focusing on creating meaningful connections through location-based interactions and ephemeral content sharing. The platform encourages users to meet in real life by highlighting nearby potential matches and facilitating spontaneous encounters through its innovative "Moments" feature.

## 🏗️ Architecture

The project follows a client-server architecture with:

1. **iOS Mobile Application** - Built with SwiftUI, implementing MVVM architecture
2. **RESTful Backend API** - Node.js/Express server with MongoDB database

## 🔑 Key Features

### 📱 Mobile Application (iOS)
- **Authentication System**: Secure login and registration with JWT
- **Moments Feed**: Ephemeral content sharing with 24-hour expiration
- **Proximity-Based Matching**: Location-based discovery of potential matches
- **Real-time Matching**: Instant notifications when mutual interest is detected
- **Interactive Map View**: Visual representation of nearby users and moments
- **Profile Management**: User profile customization and settings

### 🖥️ Backend API
- **Secure Authentication**: JWT-based authentication with refresh token mechanism
- **Geospatial Queries**: MongoDB geospatial indexing for proximity-based features
- **Rate Limiting**: Protection against abuse with express-rate-limit
- **Auto-Expiring Content**: TTL indexes for automatic moment expiration
- **RESTful Endpoints**: Well-structured API for all app features

## 🛠️ Technical Stack

### Frontend (iOS)
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **State Management**: Combine framework with ObservableObject
- **Networking**: URLSession with async/await
- **Location Services**: CoreLocation
- **Maps**: MapKit
- **Image Handling**: Swift's built-in image processing

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (jsonwebtoken)
- **Password Security**: bcryptjs for hashing
- **API Protection**: express-rate-limit
- **Environment Variables**: dotenv

## 📋 Prerequisites

### iOS App
- macOS Ventura or later
- Xcode 14.0 or later
- iOS 16.0+ target deployment
- Swift 5.7+
- Active Apple Developer account (for TestFlight/App Store distribution)

### Backend API
- Node.js 16.x or later
- npm or yarn package manager
- MongoDB 5.0+ (local or Atlas cloud instance)
- Internet connection for external dependencies

## 🚀 Getting Started

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/AbhinavAnand241201/Vibe_LINK.git
   cd Vibe_LINK/vibelink-api
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   Create a `.env` file in the root directory with the following variables:
   ```
   PORT=3078
   MONGODB_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret
   ```

4. **Start the development server**
   ```bash
   npm run dev
   ```
   The server will be available at `http://localhost:3078`

### iOS App Setup

1. **Navigate to the iOS project directory**
   ```bash
   cd ../trial-1233
   ```

2. **Open the Xcode project**
   ```bash
   open trial-1233.xcodeproj
   ```

3. **Configure the API base URL**
   - Locate the `Constants.swift` file in the project
   - Update the `API.baseURL` value to point to your running backend server

4. **Build and run the application**
   - Select your target device or simulator
   - Press ⌘+R or click the Run button in Xcode

## 📚 API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Authenticate a user and receive JWT token

### User Endpoints
- `GET /api/users/profile` - Get current user profile
- `PUT /api/users/profile` - Update user profile
- `GET /api/users/nearby` - Find users within a specific radius

### Moments Endpoints
- `POST /api/moments` - Create a new moment
- `GET /api/moments/nearby` - Get moments within a specific radius
- `GET /api/moments/:id` - Get a specific moment
- `DELETE /api/moments/:id` - Delete a moment

### Matches Endpoints
- `POST /api/matches/like/:userId` - Like a user
- `GET /api/matches` - Get all matches
- `DELETE /api/matches/:matchId` - Remove a match

### Health Check
- `GET /api/health` - Check if the API is running

## 🧪 Testing

### Backend Testing
```bash
# Run backend tests
cd vibelink-api
npm test
```

### iOS Testing
```bash
# Open Xcode and run tests using the Test Navigator
# Or use the command line:
xcodebuild test -project trial-1233.xcodeproj -scheme trial-1233 -destination 'platform=iOS Simulator,name=iPhone 14'
```

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcryptjs for secure password storage
- **Rate Limiting**: Protection against brute force attacks
- **CORS Configuration**: Controlled cross-origin resource sharing
- **Input Validation**: Server-side validation of all inputs
- **Secure Headers**: Implementation of security-related HTTP headers

## 🌟 Future Enhancements

- **Push Notifications**: Real-time alerts for matches and nearby users
- **Chat System**: In-app messaging between matched users
- **Content Moderation**: AI-powered screening of user-generated content
- **Advanced Matching Algorithm**: Personality-based matching beyond proximity
- **Android Support**: Cross-platform expansion
- **Social Media Integration**: Connect with existing social networks
- **Event Creation**: Organize meetups and activities for users

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

- **Abhinav Anand** - [GitHub](https://github.com/AbhinavAnand241201)

## 🙏 Acknowledgements

- SwiftUI and iOS development community
- Node.js and Express.js contributors
- MongoDB team for their excellent database solution
- All open-source libraries used in this project
