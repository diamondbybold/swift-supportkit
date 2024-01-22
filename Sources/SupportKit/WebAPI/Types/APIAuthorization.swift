import Foundation

public struct APIAuthorization: Codable, Updatable {
    public let accessToken: String
    public let refreshToken: String
    
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
