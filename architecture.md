```markdown
# VibeLink Architecture

## iOS App (Swift + SwiftUI)

### File/Folder Structure
```
VibeLink/
├── Models/
│   ├── User.swift
│   ├── Moment.swift
│   └── Match.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── RegistrationView.swift
│   ├── Home/
│   │   ├── MomentFeedView.swift
│   │   └── ProximityMapView.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   └── VideoProfileEditor.swift
│   └── Chat/
│       ├── ChatView.swift
│       └── ARDirectionsView.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── MomentViewModel.swift
│   └── ChatViewModel.swift
├── Services/
│   ├── APIService.swift
│   ├── AuthService.swift
│   └── LocationService.swift
├── Utilities/
│   ├── Extensions/
│   │   └── View+Modifiers.swift
│   ├── Constants.swift
│   └── KeychainManager.swift
└── Assets/
    ├── Icons/
    ├── Stickers/
    └── LottieAnimations/
```

### Key Components
1. **State Management**
   - `@State`: Local view state (e.g., text field inputs)
   - `@ObservedObject`: ViewModels for complex state
   - `@EnvironmentObject`: Shared app state (e.g., authenticated user)

2. **Services Layer**
   - `AuthService`: Handles JWT token storage/retrieval via Keychain
   - `APIService`: Manages all API calls to backend
   - `LocationService`: Handles real-time geolocation with CLLocationManager

3. **Critical Flows**
   - Moment Upload: Compresses media + sends to `/moments` endpoint
   - Proximity Map: Polls `/users/nearby` every 30s with filtered coordinates
   - AR Directions: Integrates ARKit with MapKit coordinates from matches

---

## Backend (Node.js + Express + MongoDB)

### File/Folder Structure
```
vibelink-api/
├── config/
│   └── db.js
├── controllers/
│   ├── authController.js
│   ├── momentController.js
│   └── matchController.js
├── models/
│   ├── User.js
│   ├── Moment.js
│   └── Match.js
├── routes/
│   ├── authRoutes.js
│   ├── momentRoutes.js
│   └── matchRoutes.js
├── middleware/
│   ├── authMiddleware.js
│   └── uploadMiddleware.js
├── services/
│   ├── aiValidation.js
│   └── notificationService.js
└── utils/
    ├── jwtUtils.js
    └── locationUtils.js
```

### Core Systems
1. **Authentication Flow**
   - JWT token generation/validation with `jsonwebtoken`
   - Protected routes use `authMiddleware` to verify tokens
   - Password encryption via `bcryptjs`

2. **Real-Time Features**
   - Moment Feed: Uses MongoDB geospatial queries (`$nearSphere`) for 5km radius
   - Proximity Map: Aggregates users into anonymized clusters using `$geoWithin`

3. **AI Services**
   - `aiValidation.js`: Compares Moment media vs caption using Google Vision API
   - Compatibility Scoring: Analyzes shared Moment tags with TF-IDF algorithm

---

## Data Flow
1. **Mobile → Backend**
   - JWT sent in `Authorization: Bearer <token>` header
   - Multipart/form-data for Moment media uploads
   - WebSocket connection for live chat messages

2. **State Management**
   - **Client-Side**: SwiftUI ViewModels hold transient state
   - **Server-Side**: MongoDB stores persistent data, Redis (optional) for session caching

3. **Services Integration**
   ```mermaid
   graph LR
   A[iOS App] -->|HTTPS| B[Express API]
   B -->|Mongoose| C[MongoDB]
   B -->|Axios| D[AI Validation Microservice]
   B -->|Webhooks| E[Stripe Payments]
   ```

---

## Security Implementation
1. **Client-Side**
   - Keychain storage for JWT tokens
   - Photo/ID verification uses `Vision` framework facial recognition

2. **Server-Side**
   - Rate limiting with `express-rate-limit`
   - Helmet middleware for HTTP headers
   - MongoDB field-level encryption for sensitive data

---

## Deployment
- **iOS**: TestFlight for beta, App Store Connect for prod
- **Backend**: Dockerized container on AWS ECS
- **MongoDB**: Atlas cluster with geospatial indexing enabled
- **Media Storage**: AWS S3 + CloudFront CDN

```

> This architecture balances SwiftUI's declarative UI with Node.js's async capabilities, optimized for Gen Z-scale interactions. The JWT auth flow ensures security without sacrificing real-time performance.