import Foundation
import CoreLocation
import SwiftUI

class MomentViewModel: ObservableObject {
    @Published var moments: [Moment] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var showErrorBanner = false
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMorePages = false
    
    private let momentService = MomentService.shared
    private let locationService = LocationService.shared
    
    // MARK: - Moment Feed
    
    /// Load nearby moments based on user's current location
    func loadNearbyMoments() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                guard let location = locationService.getCurrentLocation() else {
                    await MainActor.run {
                        self.error = "Location not available. Please enable location services."
                        self.showErrorBanner = true
                        self.isLoading = false
                    }
                    return
                }
                
                let response = try await momentService.getNearbyMoments(
                    location: location,
                    page: currentPage
                )
                
                await MainActor.run {
                    // If first page, replace moments; otherwise append
                    if self.currentPage == 1 {
                        self.moments = response.moments
                    } else {
                        self.moments.append(contentsOf: response.moments)
                    }
                    
                    self.totalPages = response.pagination.pages
                    self.hasMorePages = self.currentPage < self.totalPages
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = NetworkErrorHandler.handleAPIError(error) { [weak self] () -> Void in
                        self?.loadNearbyMoments()
                    }
                    self.showErrorBanner = true
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Load the next page of moments
    func loadNextPage() {
        guard hasMorePages && !isLoading else { return }
        
        currentPage += 1
        loadNearbyMoments()
    }
    
    /// Refresh moments (reset to page 1)
    func refreshMoments() {
        currentPage = 1
        loadNearbyMoments()
    }
    
    // MARK: - Moment Creation
    
    /// Create a new moment
    /// - Parameters:
    ///   - caption: Text caption for the moment
    ///   - mediaURL: URL to the media (photo/video)
    ///   - completion: Callback with result
    func createMoment(caption: String, mediaURL: String, completion: @escaping (Result<Moment, Error>) -> Void) {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        // Define the request as a closure for retry mechanism
        let request: () async throws -> Moment = { [weak self] in
            guard let self = self else { throw NetworkError.unknown }
            
            guard let location = self.locationService.getCurrentLocation() else {
                throw NetworkError.invalidResponse
            }
            
            return try await self.momentService.createMoment(
                caption: caption,
                mediaURL: mediaURL,
                location: location
            )
        }
        
        // Use retry mechanism with exponential backoff
        Task {
            do {
                let moment = try await request()
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                    // Add the new moment to the beginning of the list
                    self.moments.insert(moment, at: 0)
                    completion(.success(moment))
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.error = NetworkErrorHandler.handleAPIError(error) { [weak self] () -> Void in
                        self?.createMoment(caption: caption, mediaURL: mediaURL, completion: completion)
                    }
                    self.showErrorBanner = true
                    self.isLoading = false
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Moment Deletion
    
    /// Delete a moment
    /// - Parameters:
    ///   - id: Moment ID to delete
    ///   - completion: Callback with result
    func deleteMoment(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        NetworkErrorHandler.retryRequest(maxRetries: 2, request: { [weak self] in
            guard let self = self else { throw NetworkError.unknown }
            return try await self.momentService.deleteMoment(id: id)
        }) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    // Remove the deleted moment from the list
                    self.moments.removeAll { $0.id == id }
                    completion(.success(()))
                    
                case .failure(let error):
                    self.error = NetworkErrorHandler.handleAPIError(error) { [weak self] () -> Void in
                        self?.deleteMoment(id: id, completion: completion)
                    }
                    self.showErrorBanner = true
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Error Handling
    
    /// Dismiss the current error
    func dismissError() {
        error = nil
        showErrorBanner = false
    }
    
    /// Retry the last failed operation
    func retryLastOperation() {
        // This would be called from the ErrorView's retry button
        if currentPage > 1 {
            loadNearbyMoments()
        } else {
            refreshMoments()
        }
    }
}
