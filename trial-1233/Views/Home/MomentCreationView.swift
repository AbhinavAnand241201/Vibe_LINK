import SwiftUI
import PhotosUI
import CoreLocation

struct MomentCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = MomentViewModel()
    @ObservedObject private var locationService = LocationService.shared
    
    @State private var caption = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingLocationAlert = false
    @State private var showingSuccessAlert = false
    
    // Temporary URL for demo purposes - in a real app, this would be uploaded to a server
    private let demoMediaURL = "https://example.com/media/placeholder.jpg"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Media")) {
                    VStack {
                        if let selectedImageData = selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(Constants.UI.cornerRadius)
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 200)
                                    .cornerRadius(Constants.UI.cornerRadius)
                                
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("Add Photo or Video")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        HStack {
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                Label("Gallery", systemImage: "photo.on.rectangle")
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            
                            Spacer()
                            
                            Button(action: {
                                showingCamera = true
                            }) {
                                Label("Camera", systemImage: "camera")
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                        .padding(.top, 8)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                }
                
                Section(header: Text("Caption")) {
                    TextEditor(text: $caption)
                        .frame(minHeight: 100)
                        .overlay(
                            VStack {
                                if caption.isEmpty {
                                    HStack {
                                        Text("What's happening right now?")
                                            .foregroundColor(.gray)
                                            .padding(.top, 8)
                                            .padding(.leading, 5)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }
                        )
                }
                
                Section {
                    if locationService.authorizationStatus == .denied || locationService.authorizationStatus == .restricted {
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Label("Enable Location Services", systemImage: "location.circle")
                                .foregroundColor(.red)
                        }
                    } else if locationService.currentLocation == nil {
                        Button(action: {
                            locationService.requestLocationPermission()
                            locationService.startUpdatingLocation()
                        }) {
                            Label("Get Current Location", systemImage: "location.circle")
                        }
                    } else if let location = locationService.currentLocation {
                        HStack {
                            Label("Current Location", systemImage: "location.fill")
                            Spacer()
                            Text(String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let error = viewModel.error {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Create Moment")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Post") {
                    postMoment()
                }
                .disabled(caption.isEmpty || selectedImageData == nil || locationService.currentLocation == nil || viewModel.isLoading)
            )
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .alert("Location Required", isPresented: $showingLocationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enable location services to create a Moment. Moments are location-based and require your current coordinates.")
            }
            .alert("Moment Created!", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Your moment has been successfully posted and will be visible to nearby users for 24 hours.")
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.2))
                    }
                }
            )
        }
        .onAppear {
            // Request location when view appears
            if locationService.authorizationStatus == .notDetermined {
                locationService.requestLocationPermission()
            }
            locationService.startUpdatingLocation()
        }
    }
    
    private func postMoment() {
        guard let location = locationService.getCurrentLocation() else {
            showingLocationAlert = true
            return
        }
        
        // In a real app, we would upload the image to a server here
        // and get back a URL to use for the mediaURL
        viewModel.createMoment(caption: caption, mediaURL: demoMediaURL) { result in
            switch result {
            case .success(_):
                showingSuccessAlert = true
            case .failure(let error):
                print("Error creating moment: \(error.localizedDescription)")
                // Error is already handled in the viewModel
            }
        }
    }
}

struct MomentCreationView_Previews: PreviewProvider {
    static var previews: some View {
        MomentCreationView()
    }
}
