import Foundation
import CoreLocation
import MapKit

struct UserCluster: Identifiable, Codable {
    let id = UUID()
    let count: Int
    let coordinates: Coordinates
    let distance: Double
    
    struct Coordinates: Codable {
        let type: String
        let coordinates: [Double]
        
        // Convert to CLLocationCoordinate2D for MapKit
        var coordinate: CLLocationCoordinate2D {
            // GeoJSON format is [longitude, latitude]
            return CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
        }
    }
    
    // CodingKeys to exclude the generated UUID from JSON
    private enum CodingKeys: String, CodingKey {
        case count, coordinates, distance
    }
}

// Custom annotation for MapKit
class ClusterAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let count: Int
    
    init(coordinate: CLLocationCoordinate2D, count: Int, distance: Double) {
        self.coordinate = coordinate
        self.count = count
        self.title = "\(count) \(count == 1 ? "person" : "people") nearby"
        self.subtitle = String(format: "%.1f km away", distance / 1000)
        super.init()
    }
}
