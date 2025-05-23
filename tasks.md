```markdown
# VibeLink MVP Build Plan

## Phase 1: Core Infrastructure
### Backend
1. **Set up Node.js project**
   - `npm init -y`
   - Install express, mongoose, dotenv, cors
   - Create basic server.js with healthcheck endpoint

2. **Configure MongoDB connection**
   - Create Atlas cluster
   - Add connection URI to .env
   - Implement db.js with Mongoose connection

3. **User Model Foundation**
   - Create User.js model with:
   ```javascript
   email: { type: String, unique: true },
   password: String,
   location: { type: { type: String }, coordinates: [Number] }
   ```
   - Add 2dsphere index

4. **JWT Auth Setup**
   - Create jwtUtils.js with sign/verify functions
   - Implement authMiddleware.js for protected routes

### iOS App
5. **Project Setup**
   - Create new SwiftUI project
   - Add "Services" folder structure
   - Install Alamofire via SPM

6. **APIService Foundation**
   - Create APIService.swift with:
   ```swift
   class APIService {
     static let shared = APIService()
     private let baseURL = "http://localhost:3000"
   }
   ```

7. **Keychain Manager**
   - Implement KeychainManager.swift with:
   ```swift
   func saveToken(_ token: String) -> Bool
   func getToken() -> String?
   ```

---

## Phase 2: Authentication Flow
### Backend
8. **Registration Endpoint**
   - POST /api/auth/register
   - Validate email/password
   - Hash password with bcryptjs
   - Return JWT

9. **Login Endpoint**
   - POST /api/auth/login
   - Compare password hashes
   - Return JWT on success

### iOS App
10. **Login View UI**
    - Create LoginView.swift with:
    - Email/password TextFields
    - "Sign In" button

11. **AuthService Implementation**
    ```swift
    class AuthService {
      func login(email: String, password: String) async throws -> AuthResponse
    }
    ```

12. **Login Integration**
    - Connect LoginView to AuthService
    - Store JWT in Keychain on success
    - Handle network errors

---

## Phase 3: Moment Core Features
### Backend
13. **Moment Model**
    ```javascript
    const MomentSchema = new Schema({
      userId: { type: Schema.Types.ObjectId, ref: 'User' },
      caption: String,
      mediaURL: String,
      location: { type: { type: String }, coordinates: [Number] },
      expiresAt: Date
    });
    ```

14. **Create Moment Endpoint**
    - POST /api/moments
    - Validate JWT
    - Store in MongoDB with 24h TTL

15. **Nearby Moments Query**
    - GET /api/moments/nearby?lat=...&lng=...
    - MongoDB $near query (5km radius)

### iOS App
16. **Moment Creation View**
    - UI for photo/video capture
    - Caption input field
    - Post button

17. **LocationService**
    ```swift
    class LocationService: NSObject, CLLocationManagerDelegate {
      static let shared = LocationService()
      func getCurrentLocation() -> CLLocation?
    }
    ```

18. **Moment Upload Flow**
    - Compress media
    - Multipart upload to /api/moments
    - Handle upload progress

---

## Phase 4: Feed & Interactions
### Backend
19. **Feed Pagination**
    - Add skip/limit to GET /api/moments/nearby
    - Default: 10 items per page

20. **Match System**
    - POST /api/matches
    - Store when user "joins" a Moment

### iOS App
21. **Vertical Feed UI**
    - SwiftUI ScrollView
    - LazyVStack for Moments
    - Swipe-up gesture handler

22. **Media Player Component**
    - AVKit integration
    - Auto-play next Moment
    - Volume controls

23. **Join Action Implementation**
    - API call to /api/matches
    - Success confirmation haptic

---

## Phase 5: Proximity Map
### Backend
24. **Cluster Endpoint**
    - GET /api/users/clusters
    - Aggregate users by 500m grid

### iOS App
25. **MapKit Integration**
    - MKMapView in SwiftUI
    - Custom annotation views

26. **Cluster Rendering**
    - Convert backend clusters to MKAnnotations
    - Dynamic circle sizing

---

## Phase 6: MVP Polish
### Backend
27. **TTL Index for Moments**
    - db.moments.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 })

28. **Rate Limiting**
    - Add express-rate-limit
    - 100 requests/15min window

### iOS App
29. **Launch Screen**
    - Lottie animation
    - Brand colors

30. **Error Handling**
    - Network error banners
    - Retry mechanisms

---

## Phase 7: Validation & Testing
31. **Postman Collection**
    - All API endpoints
    - Environment variables

32. **Snapshot Testing**
    - iOS View preview tests
    - Core components

33. **Load Testing**
    - Artillery.io config
    - 1000 concurrent users

---

## Phase 8: Deployment Prep
34. **Dockerfile**
    ```dockerfile
    FROM node:18-alpine
    COPY . .
    RUN npm ci --only=production
    CMD ["node", "server.js"]
    ```

35. **App Store Assets**
    - 1024x1024 icon
    - Preview screenshots

```

This plan creates shippable increments every 2-3 tasks. Each step produces testable output:
- After Phase 2: Full auth flow
- After Phase 4: Functional Moment feed
- After Phase 5: Interactive map
- Phase 8: Production-ready build

The LLM can execute tasks sequentially while maintaining system stability.