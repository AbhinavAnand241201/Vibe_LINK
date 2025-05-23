import Foundation
import CoreLocation
import MapKit
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var clusters: [UserCluster] = []
    @Published var annotations: [ClusterAnnotation] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private let userService = UserService.shared
    private let locationService = LocationService.shared
    
    // MARK: - Load Clusters
    
    /// Load user clusters based on current location
    func loadUserClusters() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                guard let location = locationService.getCurrentLocation() else {
                    await MainActor.run {
                        self.error = "Location not available. Please enable location services."
                        self.isLoading = false
                    }
                    return
                }
                
                // Update map region to current location
                await MainActor.run {
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
                
                let clusters = try await userService.getUserClusters(location: location)
                
                await MainActor.run {
                    self.clusters = clusters
                    
                    // Convert clusters to map annotations
                    self.annotations = clusters.map { cluster in
                        ClusterAnnotation(
                            coordinate: cluster.coordinates.coordinate,
                            count: cluster.count,
                            distance: cluster.distance
                        )
                    }
                    
                    self.isLoading = false
                }
            } catch let apiError as APIError {
                await MainActor.run {
                    self.error = apiError.message
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = "An unexpected error occurred"
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Update User Location
    
    /// Update user's location on the server
    func updateUserLocation() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                guard let location = locationService.getCurrentLocation() else {
                    await MainActor.run {
                        self.error = "Location not available. Please enable location services."
                        self.isLoading = false
                    }
                    return
                }
                
                _ = try await userService.updateUserLocation(location: location)
                
                await MainActor.run {
                    self.isLoading = false
                }
                
                // After updating location, reload clusters
                loadUserClusters()
            } catch let apiError as APIError {
                await MainActor.run {
                    self.error = apiError.message
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = "An unexpected error occurred"
                    self.isLoading = false
                }
            }
        }
    }
}
