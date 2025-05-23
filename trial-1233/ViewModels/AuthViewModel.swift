import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var user: AuthResponse?
    
    private let authService = AuthService.shared
    
    init() {
        // Check if user is already logged in
        isAuthenticated = authService.isLoggedIn()
    }
    
    func login(email: String, password: String) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await authService.login(email: email, password: password)
                
                // Update UI on main thread
                await MainActor.run {
                    self.user = response
                    self.isAuthenticated = true
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
    
    func register(email: String, password: String) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await authService.register(email: email, password: password)
                
                // Update UI on main thread
                await MainActor.run {
                    self.user = response
                    self.isAuthenticated = true
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
    
    func logout() {
        authService.logout()
        isAuthenticated = false
        user = nil
    }
}
