import Foundation

public struct APIAuthorization: Codable {
    public let accessToken: String
    public let refreshToken: String
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    public func save() {
        FileManager.default.cacheItem(self, name: "authorization", secure: true)
    }
    
    public static var saved: Self? {
        FileManager.default.cachedItem(name: "authorization", secure: true)
    }
    
    public static func delete() {
        FileManager.default.removeCachedItem(name: "authorization", secure: true)
    }
}
