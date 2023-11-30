import Foundation

public struct APIContainer<D: Decodable, M: Decodable>: Decodable {
    public let data: D
    public let meta: M?
    public let errors: [APIContainerError]?
}


public struct APIContainerError: LocalizedError, Decodable {
    public let status: String
    //    public let code: String?
    public let title: String?
    public let detail: String?
    
    public var failureReason: String? { title }
    public var recoverySuggestion: String? { detail }
}

extension Array: Error, LocalizedError where Element == APIContainerError {
    public var failureReason: String? { first?.failureReason }
    public var recoverySuggestion: String? { first?.recoverySuggestion }
}
