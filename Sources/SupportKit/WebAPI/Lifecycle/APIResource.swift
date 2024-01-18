import Foundation

open class APIResource<T: APIModel>: Fetchable, Invalidatable {
    @Published public var data: T? = nil
    @Published public var error: Error? = nil
    
    public var contentUnavailable: Bool { data == nil }
    
    @Published public var fetchedAt: Date = .distantPast
    @Published public var invalidatedAt: Date = .distantPast
    
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
    
    open func performFetch() async throws -> T? { nil }
    
    public func fetch() async {
        do {
            if error != nil { error = nil }
            data = try await performFetch()
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
}
