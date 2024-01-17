import Foundation

@MainActor
open class APIResource<T: APIModel>: ObservableObject, Invalidatable {
    @Published public var data: T? = nil
    @Published public private(set) var error: Error? = nil
    
    @Published public private(set) var fetchedAt: Date = .distantPast
    @Published public private(set) var invalidatedAt: Date = .distantPast
    
    deinit { untracking() }
    
    public init() {
        tracking { [weak self] in
            for await _ in Self.invalidates.map({ $0.object }) {
                self?.invalidate()
            }
        }
        
        tracking { [weak self] in
            for await object in T.updates.compactMap({ $0.object as? T }) {
                if object.id == self?.data?.id {
                    self?.data = object
                }
            }
        }
    }
    
    open func performFetch() async throws { }
    
    public func fetch() async {
        do {
            if error != nil { error = nil }
            try await performFetch()
            fetchedAt = .now
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
    
    public func refetch() async {
        data = nil
        fetchedAt = .distantPast
        
        await fetch()
    }
    
    public func needsUpdate(_ expiration: TimeInterval = 120) -> Bool {
        if invalidatedAt > fetchedAt { return true }
        else { return fetchedAt.hasExpired(in: expiration) }
    }
    
    public func invalidate() {
        invalidatedAt = .now
    }
}
