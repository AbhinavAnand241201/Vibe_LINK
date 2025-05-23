import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(statusCode: Int, message: String?)
    case noInternet
    case unauthorized
    case timeout
    case unknown
    
    var userFriendlyMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again later."
        case .requestFailed:
            return "Network request failed. Please check your connection."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingFailed:
            return "Could not process the data from the server."
        case .serverError(let statusCode, let message):
            if let message = message, !message.isEmpty {
                return message
            }
            return "Server error (Code: \(statusCode)). Please try again later."
        case .noInternet:
            return "No internet connection. Please check your network settings."
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .timeout:
            return "Request timed out. Please try again."
        case .unknown:
            return "An unexpected error occurred. Please try again later."
        }
    }
    
    static func handleError(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        
        let nsError = error as NSError
        
        // Check for no internet connection
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet:
                return .noInternet
            case NSURLErrorTimedOut:
                return .timeout
            case NSURLErrorUserAuthenticationRequired:
                return .unauthorized
            default:
                return .requestFailed(error)
            }
        }
        
        return .unknown
    }
}

class NetworkErrorHandler {
    static func handleAPIError(_ error: Error, retryAction: (() -> Void)? = nil) -> String {
        let networkError = NetworkError.handleError(error)
        
        // Handle specific error types
        switch networkError {
        case .unauthorized:
            // Force logout if unauthorized
            DispatchQueue.main.async {
                // Clear auth tokens
                KeychainManager.shared.deleteToken()
                
                // Post notification to trigger app-wide logout
                NotificationCenter.default.post(name: NSNotification.Name("LogoutUser"), object: nil)
            }
        default:
            break
        }
        
        return networkError.userFriendlyMessage
    }
    
    // Retry mechanism with exponential backoff
    static func retryRequest<T>(maxRetries: Int = 3, 
                            currentRetry: Int = 0,
                            delay: TimeInterval = 1.0,
                            request: @escaping () async throws -> T,
                            completion: @escaping (Result<T, Error>) -> Void) {
        
        guard currentRetry < maxRetries else {
            completion(.failure(NetworkError.unknown))
            return
        }
        
        Task {
            do {
                let result = try await request()
                completion(.success(result))
            } catch {
                let networkError = NetworkError.handleError(error)
                
                // Don't retry for certain errors
                switch networkError {
                case .unauthorized, .invalidURL, .decodingFailed:
                    completion(.failure(networkError))
                    return
                default:
                    // Exponential backoff
                    let nextDelay = delay * 2
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        retryRequest(maxRetries: maxRetries,
                                    currentRetry: currentRetry + 1,
                                    delay: nextDelay,
                                    request: request,
                                    completion: completion)
                    }
                }
            }
        }
    }
}
