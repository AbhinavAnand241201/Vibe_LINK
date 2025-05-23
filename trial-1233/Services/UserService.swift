import Foundation
import CoreLocation

class UserService {
    static let shared = UserService()
    
    private let apiService = APIService.shared
    private let keychainManager = KeychainManager.shared
    
    private init() {}
    
    /// Get user clusters based on location
    /// - Parameters:
    ///   - location: User's current location
    ///   - maxDistance: Maximum distance in meters (default: 5000m = 5km)
    ///   - gridSize: Size of grid cells in meters (default: 500m)
    /// - Returns: Array of UserCluster objects
    func getUserClusters(location: CLLocation, maxDistance: Int = 5000, gridSize: Int = 500) async throws -> [UserCluster] {
        let endpoint = "/api/users/clusters?latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)&maxDistance=\(maxDistance)&gridSize=\(gridSize)"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let response: [UserCluster] = try await apiService.request(
            endpoint: endpoint,
            token: token
        )
        
        return response
    }
    
    /// Update user's location
    /// - Parameter location: User's current location
    /// - Returns: Updated user object
    func updateUserLocation(location: CLLocation) async throws -> UserProfile {
        let endpoint = "/api/users/location"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let body: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        
        let response: UserProfile = try await apiService.request(
            endpoint: endpoint,
            method: "PUT",
            body: body,
            token: token
        )
        
        return response
    }
}
