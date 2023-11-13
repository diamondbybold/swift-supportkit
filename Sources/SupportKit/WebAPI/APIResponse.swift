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

// MARK: - Envelope
extension APIResponse {
    struct EmptyMeta: Decodable { }
    
    public func envelopeResource<D: Decodable, M: Decodable>(_ decoder: JSONDecoder) throws -> APIEnvelope<D, M> {
        let res: APIEnvelope<D, M> = try resource(decoder)
        if let errors = res.errors { throw errors }
        return res
    }
    
    public func envelopeResource<D: Decodable>(_ decoder: JSONDecoder) throws -> D {
        let res: APIEnvelope<D, EmptyMeta> = try resource(decoder)
        if let errors = res.errors { throw errors }
        return res.data
    }
    
    public func nullableEnvelopeResource<D: Decodable, M: Decodable>(_ decoder: JSONDecoder) throws -> APIEnvelope<D, M>? {
        let res: APIEnvelope<D, M>? = try nullableResource(decoder)
        guard let res else { return nil }
        if let errors = res.errors { throw errors }
        return res
    }
    
    public func envelopeResource<D: Decodable>(_ decoder: JSONDecoder) throws -> D? {
        let res: APIEnvelope<D, EmptyMeta>? = try nullableResource(decoder)
        guard let res else { return nil }
        if let errors = res.errors { throw errors }
        return res.data
    }
}
