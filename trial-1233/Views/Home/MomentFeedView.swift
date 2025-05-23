import SwiftUI
import CoreLocation

struct MomentFeedView: View {
    @StateObject private var viewModel = MomentViewModel()
    @ObservedObject private var locationService = LocationService.shared
    @State private var showingCreateMoment = false
    @State private var showingLocationAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.moments.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Moments Nearby")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Be the first to share what's happening around you!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingCreateMoment = true
                        }) {
                            Text("Create a Moment")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: 250)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(Constants.UI.cornerRadius)
                        }
                        .padding(.top)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.moments) { moment in
                                MomentCard(moment: moment)
                                    .onAppear {
                                        // Load more when reaching the end
                                        if moment.id == viewModel.moments.last?.id && viewModel.hasMorePages {
                                            viewModel.loadNextPage()
                                        }
                                    }
                            }
                            
                            if viewModel.isLoading && !viewModel.moments.isEmpty {
                                ProgressView()
                                    .padding()
                            }
                        }
                    }
                    .refreshable {
                        viewModel.refreshMoments()
                    }
                }
                
                // Error banner
                if viewModel.showErrorBanner, let errorMessage = viewModel.error {
                    VStack {
                        ErrorView(message: errorMessage) {
                            viewModel.retryLastOperation()
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .transition(.move(edge: .top))
                    .animation(.easeInOut, value: viewModel.showErrorBanner)
                    .zIndex(100)
                }
                
                // Loading indicator for initial load
                if viewModel.isLoading && viewModel.moments.isEmpty {
                    VStack(spacing: 16) {
                        ForEach(0..<3) { _ in
                            MomentCardSkeleton()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Nearby Moments")
            .navigationBarItems(
                trailing: Button(action: {
                    showingCreateMoment = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            )
            .sheet(isPresented: $showingCreateMoment) {
                MomentCreationView()
            }
            .alert("Location Required", isPresented: $showingLocationAlert) {
                Button("Settings", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable location services to view nearby moments.")
            }
            .onAppear {
                checkLocationAndLoadMoments()
            }
        }
    }
    
    private func checkLocationAndLoadMoments() {
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
        
        // Load moments if location is available, otherwise wait for location update
        if locationService.currentLocation != nil {
            viewModel.loadNearbyMoments()
        } else {
            // Wait for location to be available
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if locationService.currentLocation != nil {
                    viewModel.loadNearbyMoments()
                } else if locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways {
                    // Location permission granted but location not available yet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewModel.loadNearbyMoments()
                    }
                }
            }
        }
    }
}

// Individual moment card
struct MomentCard: View {
    let moment: Moment
    @StateObject private var matchViewModel = MatchViewModel()
    @State private var isJoining = false
    @State private var showingJoinAlert = false
    @State private var showingJoinSuccess = false
    @State private var joinMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info and timestamp
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(moment.userId.email.prefix(1)).uppercased())
                            .fontWeight(.bold)
                    )
                
                VStack(alignment: .leading) {
                    Text(moment.userId.email)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(timeAgo(from: moment.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Distance would be calculated in a real app
                Text("~2.3 km")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Media content - in a real app, this would load from the URL
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(4/3, contentMode: .fit)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                )
            
            // Caption
            Text(moment.caption)
                .padding(.horizontal)
            
            // Action buttons
            HStack(spacing: 20) {
                Button(action: {
                    showingJoinAlert = true
                }) {
                    Label("Join", systemImage: "person.crop.circle.badge.plus")
                        .font(.subheadline)
                }
                .disabled(isJoining)
                
                Button(action: {}) {
                    Label("Message", systemImage: "message")
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Expiration indicator
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    
                    Text(expiresIn(from: moment.expiresAt))
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            Divider()
        }
        .padding(.vertical, 8)
        .alert("Join this Moment?", isPresented: $showingJoinAlert) {
            TextField("Add a message (optional)", text: $joinMessage)
            
            Button("Cancel", role: .cancel) { }
            
            Button("Join") {
                joinMoment()
            }
        } message: {
            Text("Send a request to join \(moment.userId.email)'s moment. They'll be notified and can accept or decline.")
        }
        .alert("Request Sent!", isPresented: $showingJoinSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your request to join this moment has been sent. You'll be notified when they respond.")
        }
        .overlay(
            Group {
                if isJoining {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        )
    }
    
    private func joinMoment() {
        isJoining = true
        
        matchViewModel.joinMoment(momentId: moment.id, message: joinMessage.isEmpty ? nil : joinMessage) { result in
            isJoining = false
            
            switch result {
            case .success(_):
                showingJoinSuccess = true
                joinMessage = ""
            case .failure(let error):
                print("Error joining moment: \(error.localizedDescription)")
                // Error is already handled in the viewModel
            }
        }
    }
    
    // Format relative time for created at
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // Format expiration time
    private func expiresIn(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: now, to: date)
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "Expires in \(hours)h \(minutes)m"
            } else {
                return "Expires in \(minutes)m"
            }
        }
        
        return "Expiring soon"
    }
}

struct MomentFeedView_Previews: PreviewProvider {
    static var previews: some View {
        MomentFeedView()
    }
}
