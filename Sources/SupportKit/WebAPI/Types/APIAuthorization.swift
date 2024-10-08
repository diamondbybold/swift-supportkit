import Foundation

public struct APIAuthorization: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    public func save(secureKey: String) {
        FileManager.default.cacheItem(self, name: "authorization", secureKey: secureKey)
    }
    
    public static func saved(secureKey: String) -> Self? {
        FileManager.default.cachedItem(name: "authorization", secureKey: secureKey)
    }
    
    public static func delete() {
        FileManager.default.removeCachedItem(name: "authorization", secure: true)
    }
}
