import Foundation

public protocol APIGateway {
    var session: URLSession { get }
    
    var baseURL: URL { get }
    var version: String? { get }
    
    var encoder: JSONEncoder { get }
    var decoder: JSONDecoder { get }
    
    func request<T: Decodable>(_ request: APIRequest<T>) async throws -> APIResponse<T>
    
    func willSendRequest<T>(_ request: inout APIRequest<T>) async throws
    func didReceiveResponse<T>(_ response: inout APIResponse<T>, request: APIRequest<T>) async throws
}

// MARK: - Default Implementation
extension APIGateway {
    @discardableResult
    public func request<T>(_ request: APIRequest<T>) async throws -> APIResponse<T> {
        var request = request
        try await willSendRequest(&request)
        
        let urlRequest = request.urlRequest(baseURL: baseURL, encoder: encoder)
        
#if DEBUG
        print(urlRequest.cURLDescription())
#endif
        
        do {
            let result: (data: Data, response: URLResponse) = try await session.data(for: urlRequest)
            
#if DEBUG
            print("[Response] \(result.response)")
            print("[Response Body] \(String(data: result.data, encoding: .utf8) ?? "")")
#endif
            
            guard let urlResponse = result.response as? HTTPURLResponse else { throw APIError.unavailable }
            
            do {
                let resource = try decoder.decode(T.self, from: result.data)
                
                return .init(resource: resource,
                             code: urlResponse.statusCode,
                             headers: (urlResponse.allHeaderFields as? [String: String]) ?? [:])
            } catch {
#if DEBUG
                print("[Error] \(error)")
#endif
                throw error
            }
        } catch URLError.cancelled {
            throw CancellationError()
        } catch URLError.dataNotAllowed, URLError.notConnectedToInternet {
#if DEBUG
            print("[Error] Not Connected")
#endif
            throw APIError.unconnected
        } catch {
#if DEBUG
            print("[Error] \(error)")
#endif
            throw APIError.unavailable
        }
    }
    
    public func willSendRequest<T>(_ request: inout APIRequest<T>) async throws { }
    public func didReceiveResponse<T>(_ response: inout APIResponse<T>, request: APIRequest<T>) async throws { }
}

// MARK: - Utilities
extension APIGateway {
    public func clearCache() {
        session.configuration.urlCache?.removeAllCachedResponses()
    }
}
