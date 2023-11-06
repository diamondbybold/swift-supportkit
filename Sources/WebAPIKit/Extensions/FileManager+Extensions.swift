import Foundation

extension FileManager {
    public static var secureKey = "hrd3K72s9yilI8YFLM9dG8TbO6dWcQ8p"
    
    public func cacheItem<T: Encodable>(_ encodable: T, name: String, secure: Bool = false) {
        guard var data = try? JSONEncoder().encode(encodable) else { return }
        if secure { data = data.XORCipher(FileManager.secureKey) }
        let url = URL.cachedItemURL(name: name, secure: secure)
        try? data.write(to: url)
    }
    
    public func cachedItem<T: Decodable>(name: String, secure: Bool = false) -> T? {
        let url = URL.cachedItemURL(name: name, secure: secure)
        guard var data = try? Data(contentsOf: url) else { return nil }
        if secure { data = data.XORCipher(FileManager.secureKey) }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    public func removeCachedItem(name: String, secure: Bool = false) {
        let url = URL.cachedItemURL(name: name, secure: secure)
        try? removeItem(at: url)
    }
}
