import Foundation

struct Match: Identifiable, Codable {
    let id: String
    let userId: User
    let creatorId: User
    let momentId: Moment
    let status: MatchStatus
    let message: String
    let createdAt: Date
    let updatedAt: Date
    
    // Custom coding keys to match backend JSON
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case creatorId
        case momentId
        case status
        case message
        case createdAt
        case updatedAt
    }
    
    // Computed property to check if current user is the creator
    var isCreator: Bool {
        // This would need to be implemented with access to the current user ID
        // For now, we'll just return a placeholder
        return false
    }
}

enum MatchStatus: String, Codable {
    case pending
    case accepted
    case rejected
}

// Response structure for matches API
struct MatchesResponse: Codable {
    let matches: [Match]
    let pagination: Pagination
    
    struct Pagination: Codable {
        let total: Int
        let page: Int
        let pages: Int
    }
}
