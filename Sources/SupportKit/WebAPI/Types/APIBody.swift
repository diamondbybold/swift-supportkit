import Foundation

public enum APIBody {
    case jsonAny(Any, encoder: JSONEncoder)
    case jsonObject(Encodable, encoder: JSONEncoder)
    case formData([String: Any?])
}
