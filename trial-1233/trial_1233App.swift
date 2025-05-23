//
//  trial_1233App.swift
//  trial-1233
//
//  Created by ABHINAV ANAND  on 23/05/25.
//

import SwiftUI

@main
struct trial_1233App: App {
    @State private var showLaunchAnimation = true
    
    init() {
        // Add permission descriptions to Info.plist at runtime
        // These will be used when the app requests permissions
        setupPermissionDescriptions()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showLaunchAnimation ? 0 : 1)
                
                if showLaunchAnimation {
                    LaunchAnimation {
                        withAnimation(Constants.UI.standardAnimation) {
                            showLaunchAnimation = false
                        }
                    }
                    .transition(.opacity)
                }
            }
            .onAppear {
                // Setup notification observers for app-wide events
                setupNotificationObservers()
            }
        }
    }
    
    private func setupPermissionDescriptions() {
        // This function doesn't actually modify Info.plist at runtime
        // It's just a reminder of what needs to be added to the project settings
        // The actual descriptions should be added in the project's Info tab
        
        // Required permission descriptions:
        // NSLocationWhenInUseUsageDescription - VibeLink needs your location to show you nearby moments and people.
        // NSLocationAlwaysAndWhenInUseUsageDescription - VibeLink needs your location to show you nearby moments and people, even when the app is in the background.
        // NSPhotoLibraryUsageDescription - VibeLink needs access to your photo library to let you share moments.
        // NSCameraUsageDescription - VibeLink needs access to your camera to let you capture and share moments.
    }
    
    private func setupNotificationObservers() {
        // Setup notification observers for app-wide events
        // For example, handling force logout when token expires
        NotificationCenter.default.addObserver(forName: NSNotification.Name("LogoutUser"), object: nil, queue: .main) { _ in
            // Handle logout (this would typically reset the app state and navigate to login)
            // In a real app, this would be handled by an app coordinator or state manager
            print("User logged out due to expired token or other auth issue")
        }
    }
}
