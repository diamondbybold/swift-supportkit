import Foundation

public enum APIBody {
    case jsonAny(Any)
    case jsonObject(Encodable)
    case formData([String: String?])
    case multiFormData([String: Any?])
}
