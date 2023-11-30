import Foundation

public struct APIResponse {
    public let request: APIRequest
    
    public let statusCode: Int
    public let headers: [String: String]
    public let data: Data
    
    public func verify() throws {
        switch statusCode {
        case 200...299:
            break
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
    
    public func resource<T: Decodable>(_ decoder: JSONDecoder) throws -> T {
        switch statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
#if DEBUG
                print("[Decoding Error] \(error)")
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
    
    public func nullableResource<T: Decodable>(_ decoder: JSONDecoder) throws -> T? {
        guard statusCode != 204 else { return nil }
        return try resource(decoder) as T
    }
}

// MARK: - Container
extension APIResponse {
    struct EmptyMeta: Decodable { }
    
    public func container<D: Decodable, M: Decodable>(_ decoder: JSONDecoder) throws -> APIContainer<D, M> {
        let res: APIContainer<D, M> = try decoder.decode(APIContainer<D, M>.self, from: data)
        if let errors = res.errors { throw errors }
        return res
    }
    
    public func resourceInContainer<D: Decodable>(_ decoder: JSONDecoder) throws -> D {
        let res: APIContainer<D, EmptyMeta> = try container(decoder)
        guard let data = res.data else { throw APIError.unavailable }
        return data
    }
    
    public func nullableResourceInContainer<D: Decodable>(_ decoder: JSONDecoder) throws -> D? {
        guard statusCode != 204 else { return nil }
        let res: APIContainer<D, EmptyMeta> = try container(decoder)
        return res.data
    }
}
