import Foundation

@MainActor
public protocol Fetchable: ObservableObject {
    var error: Error? { get set }
    var contentUnavailable: Bool { get }
    
    var fetchedAt: Date { get set }
    var invalidatedAt: Date { get set }
    
    func fetch() async
    
    func needsUpdate(_ expiration: TimeInterval ) -> Bool
    func invalidate(refetch: Bool)
}

extension Fetchable {
    public func needsUpdate(_ expiration: TimeInterval = 120) -> Bool {
        if invalidatedAt > fetchedAt { return true }
        else { return fetchedAt.hasExpired(in: expiration) }
    }
    
    public func invalidate(refetch: Bool = false) {
        if refetch { fetchedAt = .distantPast }
        invalidatedAt = .now
    }
}
