import Foundation

public struct APIDeviceToken: Codable {
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public init(string: String) {
        self.data = string.data(using: .utf8) ?? Data()
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

extension APIDeviceToken {
    public var string: String { String(data: data, encoding: .utf8) ?? "" }
}
