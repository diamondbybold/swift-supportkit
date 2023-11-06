import Foundation
import TaskKit

public struct APIAuthorization: Codable, Updatable {
    public let accessToken: String
    public let refreshToken: String
    
    public static var saved: Self? {
        FileManager.default.cachedItem(name: "authorization", secure: true)
    }
    
    public func save() {
        FileManager.default.cacheItem(self, name: "authorization", secure: true)
    }
    
    public func delete() {
        FileManager.default.removeCachedItem(name: "authorization", secure: true)
    }
}
