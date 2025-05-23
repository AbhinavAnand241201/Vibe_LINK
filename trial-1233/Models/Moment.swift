import Foundation
import CoreLocation

struct Moment: Identifiable, Codable {
    let id: String
    let userId: User
    let caption: String
    let mediaURL: String
    let location: Location
    let expiresAt: Date
    let createdAt: Date
    
    // Custom coding keys to match backend JSON
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case caption
        case mediaURL
        case location
        case expiresAt
        case createdAt
    }
    
    // Location structure matching backend GeoJSON format
    struct Location: Codable {
        let type: String
        let coordinates: [Double]
        
        // Convert to CLLocationCoordinate2D for MapKit
        var coordinate: CLLocationCoordinate2D {
            // GeoJSON format is [longitude, latitude]
            return CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
        }
    }
}

// User model for Moment's userId field
struct User: Identifiable, Codable {
    let id: String
    let email: String
    
    // Custom coding keys to match backend JSON
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
    }
}

// Response structure for nearby moments API
struct MomentsResponse: Codable {
    let moments: [Moment]
    let pagination: Pagination
    
    struct Pagination: Codable {
        let total: Int
        let page: Int
        let pages: Int
    }
}
