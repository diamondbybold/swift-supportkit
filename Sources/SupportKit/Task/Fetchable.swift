import Foundation

@MainActor
public protocol Fetchable: ObservableObject, ObserverObject {
    var isFetching: Bool { get set }
    var error: Error? { get set }
    var contentUnavailable: Bool { get }
    
    var fetchedAt: Date { get set }
    var invalidatedAt: Date { get set }
    
    func fetch() async
    func refetch() async
    
    func needsUpdate(_ expiration: TimeInterval) -> Bool
    func invalidate(refetch: Bool)
}

extension Fetchable {
    public var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    public func needsUpdate(_ expiration: TimeInterval = 900) -> Bool {
        if invalidatedAt > fetchedAt { return true }
        else { return fetchedAt.hasExpired(in: expiration) }
    }
    
    public func invalidate(refetch: Bool = false) {
        if refetch { fetchedAt = .distantPast }
        invalidatedAt = .now
    }
}
