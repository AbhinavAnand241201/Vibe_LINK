import Foundation

class MatchService {
    static let shared = MatchService()
    
    private let apiService = APIService.shared
    private let keychainManager = KeychainManager.shared
    
    private init() {}
    
    /// Create a new match (join a moment)
    /// - Parameters:
    ///   - momentId: ID of the moment to join
    ///   - message: Optional message to send with the join request
    /// - Returns: The created Match object
    func createMatch(momentId: String, message: String? = nil) async throws -> Match {
        let endpoint = "/api/matches"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        var body: [String: Any] = ["momentId": momentId]
        if let message = message {
            body["message"] = message
        }
        
        let response: Match = try await apiService.request(
            endpoint: endpoint,
            method: "POST",
            body: body,
            token: token
        )
        
        return response
    }
    
    /// Update match status (accept/reject)
    /// - Parameters:
    ///   - matchId: ID of the match to update
    ///   - status: New status (accepted/rejected)
    /// - Returns: The updated Match object
    func updateMatchStatus(matchId: String, status: MatchStatus) async throws -> Match {
        let endpoint = "/api/matches/\(matchId)"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let body: [String: Any] = ["status": status.rawValue]
        
        let response: Match = try await apiService.request(
            endpoint: endpoint,
            method: "PUT",
            body: body,
            token: token
        )
        
        return response
    }
    
    /// Get matches for current user
    /// - Parameters:
    ///   - page: Page number for pagination
    ///   - limit: Number of items per page
    /// - Returns: MatchesResponse containing matches and pagination info
    func getMyMatches(page: Int = 1, limit: Int = 10) async throws -> MatchesResponse {
        let endpoint = "/api/matches?page=\(page)&limit=\(limit)"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let response: MatchesResponse = try await apiService.request(
            endpoint: endpoint,
            token: token
        )
        
        return response
    }
    
    /// Get a specific match by ID
    /// - Parameter id: Match ID
    /// - Returns: The requested Match object
    func getMatchById(id: String) async throws -> Match {
        let endpoint = "/api/matches/\(id)"
        
        guard let token = keychainManager.getToken() else {
            throw APIError.unauthorized
        }
        
        let response: Match = try await apiService.request(
            endpoint: endpoint,
            token: token
        )
        
        return response
    }
}
