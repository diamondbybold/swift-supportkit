import Foundation

@MainActor
open class Store: ObservableObject, Invalidatable {
    @Published public var fetchedAt: Date = .distantPast
    @Published public var invalidatedAt: Date = .distantPast
    
    @Published public var error: Error? = nil
    
    open var contentUnavailable: Bool { false }
    
    deinit { untracking() }
    
    public init() {
        tracking { [weak self] in
            for await _ in Self.invalidates.map({ $0.object }) {
                self?.invalidate()
            }
        }
    }
    
    public func needsUpdate(_ expiration: TimeInterval = 120) -> Bool { fetchedAt.hasExpired(in: expiration) }
    
    public func invalidate(tryAgain: Bool = false) {
        if tryAgain {
            error = nil
            fetchedAt = .distantPast
        }
        invalidatedAt = .now
    }
}
