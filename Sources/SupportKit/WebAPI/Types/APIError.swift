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

public struct APIValidationError: LocalizedError {
    public let name: String
    
    public init(name: String,
                type: ValidationType) {
        self.name = name
        self.type = type
    }
    
    public enum ValidationType {
        case required
        case type(String)
        case min(Double)
        case max(Double)
        case minLength(Int)
        case maxLength(Int)
    }
    
    public let type: ValidationType
    
    public var failureReason: String? {
        switch type {
        case .required: String(localized: "api-validation-error-required-\(name)-reason")
        case let .type(type): String(localized: "api-validation-error-type-\(name)-\(type)-reason")
        case let .min(min): String(localized: "api-validation-error-min-\(name)-\(min)-reason")
        case let .max(max): String(localized: "api-validation-error-max-\(name)-\(max)-reason")
        case let .minLength(min): String(localized: "api-validation-error-min-length-\(name)-\(min)-reason")
        case let .maxLength(max): String(localized: "api-validation-error-max-length-\(name)-\(max)-reason")
        }
    }
    
    public var recoverySuggestion: String? {
        switch type {
        case .required: String(localized: "api-validation-error-required-\(name)-suggestion")
        case let .type(type): String(localized: "api-validation-error-type-\(name)-\(type)-suggestion")
        case let .min(min): String(localized: "api-validation-error-min-\(name)-\(min)-suggestion")
        case let .max(max): String(localized: "api-validation-error-max-\(name)-\(max)-suggestion")
        case let .minLength(min): String(localized: "api-validation-error-min-length-\(name)-\(min)-suggestion")
        case let .maxLength(max): String(localized: "api-validation-error-max-length-\(name)-\(max)-suggestion")
        }
    }
}
