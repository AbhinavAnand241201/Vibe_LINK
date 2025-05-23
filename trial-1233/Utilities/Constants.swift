import Foundation
import SwiftUI

struct Constants {
    // API
    struct API {
        static let baseURL = "http://localhost:3078"
        static let healthEndpoint = "/api/health"
        static let authEndpoint = "/api/auth"
        static let momentsEndpoint = "/api/moments"
        static let usersEndpoint = "/api/users"
        static let matchesEndpoint = "/api/matches"
        
        // Network
        static let timeout: TimeInterval = 30
        static let retryCount = 3
        static let retryDelay: TimeInterval = 1.0
    }
    
    // Keychain
    struct Keychain {
        static let tokenKey = "auth_token"
        static let service = "com.vibelink.app"
    }
    
    // UI
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let standardPadding: CGFloat = 16
        static let buttonHeight: CGFloat = 50
        static let iconSize: CGFloat = 24
        static let avatarSize: CGFloat = 40
        static let largeAvatarSize: CGFloat = 100
        
        // Animation
        static let standardAnimation: Animation = .easeInOut(duration: 0.3)
        static let shimmerDuration: Double = 1.5
        
        // Colors
        static let primaryColor = Color.pink
        static let secondaryColor = Color.blue
        static let errorColor = Color.red
        static let successColor = Color.green
        static let warningColor = Color.orange
    }
    
    // App
    struct App {
        static let name = "VibeLink"
        static let tagline = "Find Your Moment, Not Just a Match"
        static let version = "1.0.0"
    }
    
    // Location
    struct Location {
        static let defaultRadius: Double = 5000 // 5km in meters
        static let gridSize: Double = 500 // 500m grid size for clusters
        static let updateInterval: TimeInterval = 60 // 1 minute
    }
    
    // Error Messages
    struct ErrorMessages {
        static let networkError = "Network connection error. Please check your internet connection."
        static let serverError = "Server error. Please try again later."
        static let authError = "Authentication error. Please log in again."
        static let locationError = "Location services are required. Please enable location access in settings."
        static let generalError = "Something went wrong. Please try again."
    }
}
