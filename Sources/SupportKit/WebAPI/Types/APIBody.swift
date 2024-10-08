import Foundation

public enum APIBody: Sendable {
    case jsonAny(Sendable, encoder: JSONEncoder)
    case jsonObject(Encodable & Sendable, encoder: JSONEncoder)
    case formData([String: Sendable?])
}
