import Foundation

public struct APIRequest {
    public var path: String = ""
    public var version: String? = nil
    public var method: APIMethod = .get
    public var query: [String: String?] = [:]
    public var body: APIBody? = nil
    public var headers: [String: String] = [:]
    public var cachePolicy: URLRequest.CachePolicy? = .useProtocolCachePolicy
    public var retry: Bool = true
}

// MARK: - Integration
extension APIRequest {
    public func urlRequest(baseURL: URL) -> URLRequest {
        // Compose URL
        var url = baseURL
        
        if let v = version {
            if !v.isEmpty { url = url.appendingPathComponent(v) }
        } else if let v = self.version {
            url = url.appendingPathComponent(v)
        }
        
        url = url.appendingPathComponent(path)
        
        if !query.isEmpty,
           var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems = query.compactMapValues { $0 }.map(URLQueryItem.init)
            url = components.url ?? url
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
            var data: [String] = []
            
            for (k, v) in dict {
                if let v = v {
                    data.append(k + "=" + (v.addingPercentEncodingForURLFormValue ?? ""))
                }
            }
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = data.joined(separator: "&").data(using: .utf8)!
        case .multiFormData(let dict):
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
