import Foundation

// Auth response model
struct AuthResponse: Codable {
    let _id: String
    let email: String
    let token: String
}

// User profile model
struct UserProfile: Codable {
    let _id: String
    let email: String
    let location: Location?
    
    struct Location: Codable {
        let type: String
        let coordinates: [Double]
    }
}

class AuthService {
    static let shared = AuthService()
    private let apiService = APIService.shared
    private let keychainManager = KeychainManager.shared
    
    private init() {}
    
    /// Login user with email and password
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    /// - Returns: AuthResponse containing user info and token
    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "/api/auth/login"
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let response: AuthResponse = try await apiService.request(
            endpoint: endpoint,
            method: "POST",
            body: body
        )
        
        // Save token to keychain
        _ = keychainManager.saveToken(response.token)
        
        return response
    }
    
    /// Register new user
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    /// - Returns: AuthResponse containing user info and token
    func register(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "/api/auth/register"
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let response: AuthResponse = try await apiService.request(
            endpoint: endpoint,
            method: "POST",
            body: body
        )
        
        // Save token to keychain
        _ = keychainManager.saveToken(response.token)
        
        return response
    }
    
    /// Get current user profile
    /// - Returns: User profile data
    func getCurrentUser() async throws -> UserProfile {
        let endpoint = "/api/auth/me"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let response: UserProfile = try await apiService.request(
            endpoint: endpoint,
            token: token
        )
        
        return response
    }
    
    /// Logout user by removing token
    func logout() {
        _ = keychainManager.deleteToken()
    }
    
    /// Check if user is logged in
    /// - Returns: Boolean indicating if user is logged in
    func isLoggedIn() -> Bool {
        return keychainManager.getToken() != nil
    }
}
