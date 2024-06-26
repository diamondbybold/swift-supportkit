import Foundation

public struct APIRequest {
    public var path: String
    public var version: String?
    public var method: APIMethod
    public var query: [String: String?]
    public var body: APIBody?
    public var headers: [String: String]
    public var cachePolicy: URLRequest.CachePolicy?
    public var retry: Bool
    
    public init(path: String,
                version: String? = nil,
                method: APIMethod = .get,
                query: [String: String?] = [:],
                body: APIBody? = nil,
                headers: [String: String] = [:],
                cachePolicy: URLRequest.CachePolicy? = .useProtocolCachePolicy,
                retry: Bool = true) {
        self.path = path
        self.version = version
        self.method = method
        self.query = query
        self.body = body
        self.headers = headers
        self.cachePolicy = cachePolicy
        self.retry = retry
    }
}

// MARK: - Integration
extension APIRequest {
    public func urlRequest(baseURL: URL, version: String? = nil) -> URLRequest {
        // Compose URL
        var url = baseURL
        
        // API version
        if let v = self.version, !v.isEmpty {
            url = url.appendingPathComponent(v)
        } else if let v = version {
            url = url.appendingPathComponent(v)
        }
        
        url = url.appendingPathComponent(path)
        
        // Query string
        if !query.isEmpty {
            var queryItems: [URLQueryItem] = []
            for (k, v) in query { if let v, !v.isEmpty { queryItems.append(.init(name: k.escaped, value: v.escaped)) } }
            
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                components.percentEncodedQueryItems = queryItems
                url = components.url ?? url
            }
        }
        
        // Request object
        var request = URLRequest(url: url, cachePolicy: cachePolicy ?? .useProtocolCachePolicy)
        request.httpMethod = method.rawValue
        
        if !headers.isEmpty {
            headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        if cachePolicy == nil { request.setValue("no-store", forHTTPHeaderField: "Cache-Control") }
        
        // Request body
        switch body {
        case let .jsonAny(value, encoder):
            do {
                request.httpBody = try encoder.encodeAny(value)
            } catch {
                request.httpBody = nil
#if DEBUG
                print("[Encoding Error] \(error)")
#endif
            }
        case let .jsonObject(object, encoder):
            do {
                request.httpBody = try encoder.encode(object)
            } catch {
                request.httpBody = nil
#if DEBUG
                print("[Encoding Error] \(error)")
#endif
            }
        case .formData(let dict):
            let boundary = UUID().uuidString
            var data = Data()
            
            for (k, v) in dict {
                if let value = v as? String {
                    var fieldString = "--\(boundary)\r\n"
                    fieldString += "Content-Disposition: form-data; name=\"\(k)\"\r\n"
                    fieldString += "Content-Type: text/plain; charset=utf-8\r\n"
                    fieldString += "Content-Transfer-Encoding: binary\r\n"
                    fieldString += "\r\n"
                    fieldString += value
                    fieldString += "\r\n"
                    data += fieldString.data(using: .utf8)!
                } else if let value = v as? Data {
                    var fieldString = "--\(boundary)\r\n"
                    fieldString += "Content-Disposition: form-data; name=\"\(k)\"; filename=\"\(UUID().uuidString).jpg\"\r\n"
                    fieldString += "Content-Type: image/jpeg\r\n"
                    fieldString += "Content-Transfer-Encoding: binary\r\n"
                    fieldString += "\r\n"
                    data += fieldString.data(using: .utf8)!
                    data += value
                    data += "\r\n".data(using: .utf8)!
                } else if let stringArray = v as? [String] {
                    for value in stringArray {
                        var fieldString = "--\(boundary)\r\n"
                        fieldString += "Content-Disposition: form-data; name=\"\(k)\"\r\n"
                        fieldString += "Content-Type: text/plain; charset=utf-8\r\n"
                        fieldString += "Content-Transfer-Encoding: binary\r\n"
                        fieldString += "\r\n"
                        fieldString += value
                        fieldString += "\r\n"
                        data += fieldString.data(using: .utf8)!
                    }
                } else if let dataArray = v as? [Data] {
                    for value in dataArray {
                        var fieldString = "--\(boundary)\r\n"
                        fieldString += "Content-Disposition: form-data; name=\"\(k)\"; filename=\"\(UUID().uuidString).jpg\"\r\n"
                        fieldString += "Content-Type: image/jpeg\r\n"
                        fieldString += "Content-Transfer-Encoding: binary\r\n"
                        fieldString += "\r\n"
                        data += fieldString.data(using: .utf8)!
                        data += value
                        data += "\r\n".data(using: .utf8)!
                    }
                }
            }
            
            let boundaryString = "--\(boundary)--"
            data += boundaryString.data(using: .utf8)!
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = data
        default:
            request.httpBody = nil
        }
        
        return request
    }
}
