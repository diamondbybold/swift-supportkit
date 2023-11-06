import Foundation

public struct APIResponse<T: Decodable> {
    public var resource: T? = nil
    
    public var code: Int = 0
    public var headers: [String: String] = [:]
    
    public func verify() throws -> T {
        switch code {
        case 200...299:
            if let resource {
                return resource
            } else {
#if DEBUG
                print("[Error] Unavailable")
#endif
                throw APIError.unavailable
            }
        case 401:
#if DEBUG
            print("[Error] Unauthorized")
#endif
            throw APIError.unauthorized
        case 403:
#if DEBUG
            print("[Error] Forbidden")
#endif
            throw APIError.forbidden
        case 404:
#if DEBUG
            print("[Error] Unavailable")
#endif
            throw APIError.unavailable
        case 400, 405...499:
#if DEBUG
            print("[Error] Unprocessable")
#endif
            throw APIError.unprocessable
        default:
#if DEBUG
            print("[Error] Unavailable")
#endif
            throw APIError.unavailable
        }
    }
    
    public func verify() throws -> T? {
        guard code != 204 else { return nil }
        return try verify() as T
    }
}
