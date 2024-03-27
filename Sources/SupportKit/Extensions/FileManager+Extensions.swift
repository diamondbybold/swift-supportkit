import Foundation

extension FileManager {
    public func cacheItem<T: Encodable>(_ encodable: T, name: String, secureKey: String? = nil) {
        guard var data = try? JSONEncoder().encode(encodable) else { return }
        if let secureKey { data = data.XORCipher(secureKey) }
        let url = URL.cachedItemURL(name: name, secure: secureKey != nil)
        try? data.write(to: url)
    }
    
    public func cachedItem<T: Decodable>(name: String, secureKey: String? = nil) -> T? {
        let url = URL.cachedItemURL(name: name, secure: secureKey != nil)
        guard var data = try? Data(contentsOf: url) else { return nil }
        if let secureKey { data = data.XORCipher(secureKey) }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    public func removeCachedItem(name: String, secure: Bool = false) {
        let url = URL.cachedItemURL(name: name, secure: secure)
        try? removeItem(at: url)
    }
}
