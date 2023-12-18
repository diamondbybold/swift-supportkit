import Foundation

@MainActor
open class Store: ObservableObject, Invalidatable {
    @Published public var fetchedAt: Date = .distantPast
    @Published public var updatedAt: Date = .distantPast
    @Published public var invalidatedAt: Date = .distantPast
    
    @Published public var error: Error? = nil
    
    open var contentUnavailable: Bool { false }
    
    deinit { untracking() }
    
    public init() {
        tracking { [weak self] in
            for await _ in Self.invalidates.map({ $0.object }) {
                self?.invalidatedAt = .now
            }
        }
    }
    
    public func needsUpdate(_ expiration: TimeInterval = 120) -> Bool {
        if invalidatedAt > updatedAt { return true }
        else if updatedAt > fetchedAt { return updatedAt.hasExpired(in: expiration) }
        else { return fetchedAt.hasExpired(in: expiration) }
    }
    
    public func updateTimestamps() {
        error = nil
        if fetchedAt == .distantPast { fetchedAt = .now }
        else { updatedAt = .now }
    }
    
    public func resetTimestamps() {
        error = nil
        fetchedAt = .distantPast
        updatedAt = .distantPast
        invalidatedAt = .distantPast
    }
    
    public func invalidate() {
        error = nil
        invalidatedAt = .now
    }
}
