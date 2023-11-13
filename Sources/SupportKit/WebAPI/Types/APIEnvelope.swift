import Foundation

public struct APIEnvelope<D: Decodable, M: Decodable>: Decodable {
    public let data: D
    public let meta: M?
    public let errors: [APIEnvelopeError]?
}


public struct APIEnvelopeError: LocalizedError, Decodable {
    public let status: String
    public let code: String?
    public let title: String?
    public let detail: String?
}

extension Array: Error where Element == APIEnvelopeError { }
