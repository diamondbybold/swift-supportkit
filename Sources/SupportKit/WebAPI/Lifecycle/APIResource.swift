import Foundation

open class APIResource<T: APIModel>: Fetchable, Invalidatable {
    @Published public var data: T? = nil
    
    public var contentUnavailable: Bool { data == nil }
    
    @Published public var isFetching: Bool = false
    @Published public var error: Error? = nil
    
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
                guard let self else { return }
                
                if object.id == data?.id {
                    data = object
                }
            }
        }
    }
    
    open func performFetch() async throws -> T? { nil }
    
    public func fetch() async {
        do {
            isFetching = true
            
            data = try await performFetch()
            fetchedAt = .now
            
            isFetching = false
            error = nil
        } catch is CancellationError {
            isFetching = false
        } catch {
            isFetching = false
            self.error = error
        }
    }
    
    public func refetch() async {
        data = nil
        fetchedAt = .distantPast
        
        await fetch()
    }
}
