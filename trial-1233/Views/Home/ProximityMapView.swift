import SwiftUI
import MapKit
import CoreLocation

struct ProximityMapView: View {
    @StateObject private var viewModel = UserViewModel()
    @ObservedObject private var locationService = LocationService.shared
    @State private var showingLocationAlert = false
    @State private var mapType: MKMapType = .standard
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map view
                Map(coordinateRegion: $viewModel.region, 
                    showsUserLocation: true,
                    annotationItems: viewModel.clusters) { cluster in
                    MapAnnotation(coordinate: cluster.coordinates.coordinate) {
                        ClusterMarker(count: cluster.count)
                            .onTapGesture {
                                // Center the map on the cluster
                                viewModel.region.center = cluster.coordinates.coordinate
                            }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .mapStyle(mapType == .standard ? .standard : .hybrid)
                
                // Error view
                if let error = viewModel.error {
                    VStack {
                        Spacer()
                        
                        Text(error)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(Constants.UI.cornerRadius)
                            .padding()
                        
                        Spacer().frame(height: 40)
                    }
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
                
                // Map controls
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 10) {
                            // Map type toggle
                            Button(action: {
                                mapType = mapType == .standard ? .hybrid : .standard
                            }) {
                                Image(systemName: mapType == .standard ? "map" : "map.fill")
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            
                            // Refresh button
                            Button(action: {
                                viewModel.loadUserClusters()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            
                            // Center on user button
                            Button(action: {
                                if let location = locationService.currentLocation {
                                    viewModel.region.center = location.coordinate
                                } else {
                                    showingLocationAlert = true
                                }
                            }) {
                                Image(systemName: "location")
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Nearby People")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Location Required", isPresented: $showingLocationAlert) {
                Button("Settings", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable location services to view nearby people.")
            }
            .onAppear {
                checkLocationAndLoadClusters()
            }
        }
    }
    
    private func checkLocationAndLoadClusters() {
        // Request location permission if not determined
        if locationService.authorizationStatus == .notDetermined {
            locationService.requestLocationPermission()
        }
        
        // Start updating location
        locationService.startUpdatingLocation()
        
        // Check if location is available
        if locationService.authorizationStatus == .denied || locationService.authorizationStatus == .restricted {
            showingLocationAlert = true
            return
        }
        
        // Load clusters if location is available, otherwise wait for location update
        if locationService.currentLocation != nil {
            // Update user location on server
            viewModel.updateUserLocation()
        } else {
            // Wait for location to be available
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if locationService.currentLocation != nil {
                    viewModel.updateUserLocation()
                } else if locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways {
                    // Location permission granted but location not available yet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewModel.updateUserLocation()
                    }
                }
            }
        }
    }
}

// Custom marker for user clusters
struct ClusterMarker: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.pink)
                .frame(width: markerSize, height: markerSize)
                .shadow(radius: 2)
            
            Text("\(count)")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // Dynamic size based on count
    private var markerSize: CGFloat {
        let baseSize: CGFloat = 40
        let maxSize: CGFloat = 60
        
        if count <= 5 {
            return baseSize
        } else if count <= 10 {
            return baseSize + 5
        } else if count <= 20 {
            return baseSize + 10
        } else {
            return maxSize
        }
    }
    
    private var fontSize: CGFloat {
        let baseSize: CGFloat = 14
        
        if count < 10 {
            return baseSize
        } else if count < 100 {
            return baseSize - 2
        } else {
            return baseSize - 4
        }
    }
}

struct ProximityMapView_Previews: PreviewProvider {
    static var previews: some View {
        ProximityMapView()
    }
}
