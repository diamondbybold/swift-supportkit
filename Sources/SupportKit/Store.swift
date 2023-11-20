import Foundation

@MainActor
open class Store: ObservableObject, Invalidatable {
    @Published public var lastUpdate: Date = .distantPast
    @Published public var lastInvalidate: Date = .distantPast
    
    @Published public var error: Error? = nil
    
    public var isReady: Bool { !(lastUpdate == .distantPast && lastInvalidate == .distantPast) }
    
    deinit { untracking() }
    
    public init() {
        tracking { [weak self] in
            for await _ in Self.invalidates.map({ $0.object }) {
                self?.invalidate()
            }
        }
    }
    
    public func needsUpdate(_ expiration: TimeInterval = 120) -> Bool { lastUpdate.hasExpired(in: expiration) }
    public func invalidate() { lastUpdate = .distantPast; lastInvalidate = .now }
}
