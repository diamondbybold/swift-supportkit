import Foundation

public typealias APIResults<T> = (elements: [T], total: Int)

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
        guard statusCode != 204, statusCode != 404 else { return nil }
        return try resource(decoder) as T
    }
    
    public func emptyableResource<T: Decodable>(_ decoder: JSONDecoder) throws -> [T] {
        guard statusCode != 204, statusCode != 404 else { return [] }
        return try resource(decoder) as [T]
    }
}

// MARK: - Container
extension APIResponse {
    struct Container<D: Decodable, M: Decodable>: Decodable {
        public let data: D?
        public let meta: M?
        public let errors: [ContainerError]?
        
        public init(data: D?, meta: M?, errors: [ContainerError]?) {
            self.data = data
            self.meta = meta
            self.errors = errors
        }
    }
    
    struct EmptyData: Decodable { }
    struct EmptyMeta: Decodable { }
    struct PaginationMeta: Decodable { let count: Int?; let total: Int? }
    
    public struct ContainerError: LocalizedError, Decodable {
        public let status: String
        public let code: String?
        public let title: String?
        public let detail: String?
        
        public var failureReason: String? { title }
        public var recoverySuggestion: String? { detail }
        
        public init(status: String, code: String?, title: String?, detail: String?) {
            self.status = status
            self.code = code
            self.title = title
            self.detail = detail
        }
    }
    
    public func verifyInContainer(_ decoder: JSONDecoder) throws {
        do {
            try verify()
        } catch {
            let erros = errorInContainer(decoder)
            throw erros.isEmpty ? error : erros
        }
    }
    
    public func container<D: Decodable, M: Decodable>(_ decoder: JSONDecoder) throws -> (data: D, meta: M) {
        let res: Container<D, M>
        do {
            res = try decoder.decode(Container<D, M>.self, from: data)
        } catch {
#if DEBUG
            print("[Decoding Error] \(error)")
            print("[Error] Unavailable")
#endif
            throw APIError.unavailable
        }
        if let errors = res.errors { throw errors }
        guard let data = res.data, let meta = res.meta else { throw APIError.unavailable }
        return (data: data, meta: meta)
    }
    
    public func nullableContainer<D: Decodable, M: Decodable>(_ decoder: JSONDecoder) throws -> (data: D?, meta: M?) {
        guard statusCode != 204, statusCode != 404 else { return (data: nil, meta: nil) }
        
        let res: Container<D, M>
        do {
            res = try decoder.decode(Container<D, M>.self, from: data)
        } catch {
#if DEBUG
            print("[Decoding Error] \(error)")
            print("[Error] Unavailable")
#endif
            throw APIError.unavailable
        }
        if let errors = res.errors { throw errors }
        return (data: res.data, meta: res.meta)
    }
    
    public func resourceInContainer<D: Decodable>(_ decoder: JSONDecoder) throws -> D {
        let res: Container<D, EmptyMeta>
        do {
            res = try decoder.decode(Container<D, EmptyMeta>.self, from: data)
        } catch {
#if DEBUG
            print("[Decoding Error] \(error)")
            print("[Error] Unavailable")
#endif
            throw APIError.unavailable
        }
        if let errors = res.errors { throw errors }
        guard let data = res.data else { throw APIError.unavailable }
        return data
    }
    
    public func nullableResourceInContainer<D: Decodable>(_ decoder: JSONDecoder) throws -> D? {
        guard statusCode != 204, statusCode != 404 else { return nil }
        return try resourceInContainer(decoder)
    }
    
    public func emptyableResourceInContainer<D: Decodable>(_ decoder: JSONDecoder) throws -> [D] {
        guard statusCode != 204, statusCode != 404 else { return [] }
        return try resourceInContainer(decoder)
    }
    
    public func pagedResourceInContainer<D: Decodable>(_ decoder: JSONDecoder) throws -> (elements: D, total: Int) {
        let res: Container<D, PaginationMeta>
        do {
            res = try decoder.decode(Container<D, PaginationMeta>.self, from: data)
        } catch {
#if DEBUG
            print("[Decoding Error] \(error)")
            print("[Error] Unavailable")
#endif
            throw APIError.unavailable
        }
        if let errors = res.errors { throw errors }
        guard let data = res.data else { throw APIError.unavailable }
        return (elements: data, total: res.meta?.count ?? res.meta?.total ?? 0)
    }
    
    public func emptyablePagedResourceInContainer<D: Decodable>(_ decoder: JSONDecoder) throws -> (elements: [D], total: Int) {
        guard statusCode != 204, statusCode != 404 else { return ([], 0) }
        return try pagedResourceInContainer(decoder)
    }
    
    public func errorInContainer(_ decoder: JSONDecoder) -> [ContainerError] {
        guard let res = try? decoder.decode(Container<EmptyData, EmptyMeta>.self, from: data) else { return [] }
        return res.errors ?? []
    }
}

// MARK: - Utils
extension Array: Error, LocalizedError where Element == APIResponse.ContainerError {
    public var status: String? { first?.status }
    public var errorCode: String? { first?.code }
    public var failureReason: String? { first?.failureReason }
    public var recoverySuggestion: String? { first?.recoverySuggestion }
}
