import Foundation
import CoreLocation

class MomentService {
    static let shared = MomentService()
    
    private let apiService = APIService.shared
    private let keychainManager = KeychainManager.shared
    
    private init() {}
    
    /// Create a new moment
    /// - Parameters:
    ///   - caption: Text caption for the moment
    ///   - mediaURL: URL to the media (photo/video)
    ///   - location: User's current location
    /// - Returns: The created Moment object
    func createMoment(caption: String, mediaURL: String, location: CLLocation) async throws -> Moment {
        let endpoint = "/api/moments"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let body: [String: Any] = [
            "caption": caption,
            "mediaURL": mediaURL,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        
        let response: Moment = try await apiService.request(
            endpoint: endpoint,
            method: "POST",
            body: body,
            token: token
        )
        
        return response
    }
    
    /// Get nearby moments based on user's location
    /// - Parameters:
    ///   - location: User's current location
    ///   - maxDistance: Maximum distance in meters (default: 5000m = 5km)
    ///   - page: Page number for pagination
    ///   - limit: Number of items per page
    /// - Returns: MomentsResponse containing moments and pagination info
    func getNearbyMoments(location: CLLocation, maxDistance: Int = 5000, page: Int = 1, limit: Int = 10) async throws -> MomentsResponse {
        let endpoint = "/api/moments/nearby?latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)&maxDistance=\(maxDistance)&page=\(page)&limit=\(limit)"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let response: MomentsResponse = try await apiService.request(
            endpoint: endpoint,
            token: token
        )
        
        return response
    }
    
    /// Get a specific moment by ID
    /// - Parameter id: Moment ID
    /// - Returns: The requested Moment object
    func getMomentById(id: String) async throws -> Moment {
        let endpoint = "/api/moments/\(id)"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let response: Moment = try await apiService.request(
            endpoint: endpoint,
            token: token
        )
        
        return response
    }
    
    /// Delete a moment
    /// - Parameter id: Moment ID to delete
    /// - Returns: Success message
    func deleteMoment(id: String) async throws -> [String: String] {
        let endpoint = "/api/moments/\(id)"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let response: [String: String] = try await apiService.request(
            endpoint: endpoint,
            method: "DELETE",
            token: token
        )
        
        return response
    }
}
