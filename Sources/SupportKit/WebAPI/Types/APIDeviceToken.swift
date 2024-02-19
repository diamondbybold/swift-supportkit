import Foundation

public struct APIDeviceToken: Codable {
    public let data: Data?
    public let string: String?
    
    public init(data: Data) {
        self.data = data
        self.string = nil
    }
    
    public init(string: String) {
        self.data = nil
        self.string = string
    }
    
    public func save() {
        FileManager.default.cacheItem(self, name: "device-token", secure: true)
    }
    
    public static var saved: Self? {
        FileManager.default.cachedItem(name: "device-token", secure: true)
    }
    
    public static func delete() {
        FileManager.default.removeCachedItem(name: "device-token", secure: true)
    }
}
