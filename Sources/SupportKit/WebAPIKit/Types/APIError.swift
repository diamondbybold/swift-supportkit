import Foundation

public enum APIError: LocalizedError {
    case unconnected
    case unavailable
    case unprocessable
    case unauthorized
    case forbidden
}
