import Foundation

public enum APIError: LocalizedError {
    case unknown
    case unconnected
    case clientError(Int)
    case serverError(Int)
}

public struct APIValidationError: LocalizedError {
    public let name: String
    
    public enum ValidationType: Sendable {
        case required
        case type(String)
        case min(Double)
        case max(Double)
        case minLength(Int)
        case maxLength(Int)
    }
    
    public let type: ValidationType
    
    public init(name: String,
                type: ValidationType) {
        self.name = name
        self.type = type
    }
}

public struct APITaggedError: LocalizedError {
    let tag: String
    
    public init(tag: String) {
        self.tag = tag
    }
}

public struct APICustomError: LocalizedError {
    let title: String?
    let description: String?
    
    public init(title: String?, description: String?) {
        self.title = title
        self.description = description
    }
}
