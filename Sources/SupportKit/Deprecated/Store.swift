import Foundation

@MainActor
open class Store: ObservableObject, Invalidatable {
    @Published public var fetchedAt: Date = .distantPast
    @Published public var invalidatedAt: Date = .distantPast
    
    @Published public var error: Error? = nil
    
    open var contentUnavailable: Bool { false }
    
    public var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    deinit { untracking() }
    
    public init() {
        tracking { [weak self] in
            for await _ in Self.invalidates.map({ $0.object }) {
                self?.invalidate()
            }
        }
    }
    
    open func needsUpdate(_ expiration: TimeInterval = 900) -> Bool {
        if invalidatedAt > fetchedAt { return true }
        else { return fetchedAt.hasExpired(in: expiration) }
    }
    
    open func invalidate(tryAgain: Bool = false) {
        if tryAgain { fetchedAt = .distantPast }
        invalidatedAt = .now
    }
}
