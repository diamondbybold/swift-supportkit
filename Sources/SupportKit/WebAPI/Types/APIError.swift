import Foundation

public enum APIError: LocalizedError {
    case unconnected
    case unavailable
    case unprocessable
    case unauthorized
    case forbidden
    
    public var failureReason: String? {
        switch self {
        case .unconnected: String(localized: "api-error-unconnected-reason")
        case .unavailable: String(localized: "api-error-unavailable-reason")
        case .unprocessable: String(localized: "api-error-unprocessable-reason")
        case .unauthorized: String(localized: "api-error-unauthorized-reason")
        case .forbidden: String(localized: "api-error-forbidden-reason")
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .unconnected: String(localized: "api-error-unconnected-suggestion")
        case .unavailable: String(localized: "api-error-unavailable-suggestion")
        case .unprocessable: String(localized: "api-error-unprocessable-suggestion")
        case .unauthorized: String(localized: "api-error-unauthorized-suggestion")
        case .forbidden: String(localized: "api-error-forbidden-suggestion")
        }
    }
}
