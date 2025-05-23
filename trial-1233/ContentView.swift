//
//  ContentView.swift
//  trial-1233
//
//  Created by ABHINAV ANAND  on 23/05/25.
//
// Updated with fixes for Swift compiler errors

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // Main app content with tabs
                MainContentView(authViewModel: authViewModel)
            } else {
                // Authentication flow
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}

// Main app content
struct MainContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Moment Feed Tab
            MomentFeedView()
                .tabItem {
                    Label("Moments", systemImage: "photo.stack")
                }
                .tag(0)
            
            // Matches Tab
            MatchesView()
                .tabItem {
                    Label("Matches", systemImage: "person.2")
                }
                .tag(1)
            
            // Proximity Map
            ProximityMapView()
                .tabItem {
                    Label("Nearby", systemImage: "map")
                }
                .tag(2)
            
            // Profile Tab with Logout
            ProfilePlaceholderView(authViewModel: authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(3)
        }
    }
}

// Placeholder for Proximity Map
struct ProximityMapPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Proximity Map")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Coming soon in the next phase!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// Placeholder for Profile
struct ProfilePlaceholderView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Profile")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your profile settings will be available here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Logout") {
                authViewModel.logout()
            }
            .padding()
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(Constants.UI.cornerRadius)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
