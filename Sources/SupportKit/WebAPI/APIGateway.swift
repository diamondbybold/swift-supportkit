import Foundation

public protocol APIGateway {
    var session: URLSession { get }
    
    var baseURL: URL { get }
    var version: String? { get }
    
    func request(_ request: APIRequest) async throws -> APIResponse
    
    func willSendRequest(_ request: inout APIRequest) async throws
    func didReceiveResponse(_ response: inout APIResponse) async throws
}

// MARK: - Default Implementation
extension APIGateway {
    @discardableResult
    public func request(_ request: APIRequest) async throws -> APIResponse {
        var request = request
        try await willSendRequest(&request)
        
        let urlRequest = request.urlRequest(baseURL: baseURL, version: version)
        
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
            
            var resource = APIResponse(request: request,
                                       statusCode: urlResponse.statusCode,
                                       headers: (urlResponse.allHeaderFields as? [String: String]) ?? [:],
                                       data: result.data)
            
            try await didReceiveResponse(&resource)
            
            return resource
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
    
    public func willSendRequest(_ request: inout APIRequest) async throws { }
    public func didReceiveResponse(_ response: inout APIResponse) async throws { }
}

// MARK: - Request Extensions
extension APIRequest {
    public func response(on gateway: APIGateway) async throws -> APIResponse { try await gateway.request(self) }
}

// MARK: - Notifications
extension Notification.Name {
    public static let APIGatewayUnconnected = Notification.Name("APIGatewayUnconnected")
    public static let APIGatewayUnauthorized = Notification.Name("APIGatewayUnauthorized")
    public static let APIGatewayForbidden = Notification.Name("APIGatewayForbidden")
    
    public static let APIGatewayDataInserted = Notification.Name("APIGatewayDataInserted")
    public static let APIGatewayDataUpdated = Notification.Name("APIGatewayDataUpdated")
    public static let APIGatewayDataDeleted = Notification.Name("APIGatewayDataDeleted")
    public static let APIGatewayDataInvalidated = Notification.Name("APIGatewayDataInvalidated")
}

// MARK: - Utilities
extension APIGateway {
    public func clearCache() {
        session.configuration.urlCache?.removeAllCachedResponses()
    }
}
