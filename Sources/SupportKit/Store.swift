import Foundation

open class Store: Context, Invalidatable {
    @Published public var lastUpdate: Date = .distantPast
    @Published public var lastInvalidate: Date = .distantPast
    
    public override init() {
        super.init()
        
        tracking { [weak self] in
            for await _ in Self.invalidates.map({ $0.object }) {
                self?.invalidate()
            }
        }
    }
    
    public func needsUpdate(_ expiration: TimeInterval = 120) -> Bool {
        lastUpdate.hasExpired(in: expiration)
    }
    
    public func invalidate() { lastInvalidate = .now }
}
