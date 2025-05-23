import Foundation
import SwiftUI

class MatchViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMorePages = false
    
    private let matchService = MatchService.shared
    
    // MARK: - Fetch Matches
    
    /// Load matches for the current user
    func loadMyMatches() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await matchService.getMyMatches(
                    page: currentPage
                )
                
                await MainActor.run {
                    // If first page, replace matches; otherwise append
                    if self.currentPage == 1 {
                        self.matches = response.matches
                    } else {
                        self.matches.append(contentsOf: response.matches)
                    }
                    
                    self.totalPages = response.pagination.pages
                    self.hasMorePages = self.currentPage < self.totalPages
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
    
    /// Load the next page of matches
    func loadNextPage() {
        guard hasMorePages && !isLoading else { return }
        
        currentPage += 1
        loadMyMatches()
    }
    
    /// Refresh matches (reset to page 1)
    func refreshMatches() {
        currentPage = 1
        loadMyMatches()
    }
    
    // MARK: - Join Moment (Create Match)
    
    /// Join a moment (create a match)
    /// - Parameters:
    ///   - momentId: ID of the moment to join
    ///   - message: Optional message to send with the join request
    ///   - completion: Callback with result
    func joinMoment(momentId: String, message: String? = nil, completion: @escaping (Result<Match, Error>) -> Void) {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let match = try await matchService.createMatch(
                    momentId: momentId,
                    message: message
                )
                
                await MainActor.run {
                    self.isLoading = false
                    // Add the new match to the beginning of the list
                    self.matches.insert(match, at: 0)
                    completion(.success(match))
                }
            } catch let apiError as APIError {
                await MainActor.run {
                    self.error = apiError.message
                    self.isLoading = false
                    completion(.failure(apiError))
                }
            } catch {
                await MainActor.run {
                    self.error = "An unexpected error occurred"
                    self.isLoading = false
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Update Match Status
    
    /// Update match status (accept/reject)
    /// - Parameters:
    ///   - matchId: ID of the match to update
    ///   - status: New status (accepted/rejected)
    ///   - completion: Callback with result
    func updateMatchStatus(matchId: String, status: MatchStatus, completion: @escaping (Result<Match, Error>) -> Void) {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let updatedMatch = try await matchService.updateMatchStatus(
                    matchId: matchId,
                    status: status
                )
                
                await MainActor.run {
                    self.isLoading = false
                    
                    // Update the match in the list
                    if let index = self.matches.firstIndex(where: { $0.id == matchId }) {
                        self.matches[index] = updatedMatch
                    }
                    
                    completion(.success(updatedMatch))
                }
            } catch let apiError as APIError {
                await MainActor.run {
                    self.error = apiError.message
                    self.isLoading = false
                    completion(.failure(apiError))
                }
            } catch {
                await MainActor.run {
                    self.error = "An unexpected error occurred"
                    self.isLoading = false
                    completion(.failure(error))
                }
            }
        }
    }
}
