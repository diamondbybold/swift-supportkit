import Foundation

extension URL {
    public init?(string: String, query: [String: String?]) {
        guard var components = URLComponents(string: string) else { return nil }
        components.queryItems = query.compactMapValues { $0 }.map(URLQueryItem.init)
        guard let newString = components.string else { return nil }
        self.init(string: newString)
    }
    
    public init?(baseURL: URL, path: String, query: [String: String?]) {
        let url = baseURL.appendingPathComponent(path)
        guard var components = URLComponents(string: url.absoluteString) else { return nil }
        components.queryItems = query.compactMapValues { $0 }.map(URLQueryItem.init)
        guard let newString = components.string else { return nil }
        self.init(string: newString)
    }
    
    public var queryDictionary: [String: String] {
        guard let items = URLComponents(string: absoluteString)?.queryItems else { return [:] }
        var aux: [String: String] = [:]
        for item in items { aux[item.name] = item.value }
        return aux
    }
}

extension URL {
    /*var lastUpdate: Date? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else { return nil }
        return attributes[.modificationDate] as? Date
    }*/
    
    public static func cachedItemURL(name: String, secure: Bool = false) -> URL {
        URL.cachesDirectory
            .appending(path: secure ? name.SHA256 : name)
            .appendingPathExtension("json")
    }
}
