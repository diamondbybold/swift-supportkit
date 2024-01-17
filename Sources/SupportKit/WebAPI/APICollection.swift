import Foundation

@MainActor
open class APICollection<T: APIModel>: ObservableObject, Invalidatable {
    @Published public var data: [T] = []
    @Published public private(set) var error: Error? = nil
    
    @Published public var total: Int = 0
    @Published public private(set) var currentPage: Int = 1
    
    public var hasMoreContent: Bool { data.count < total }
    
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
                self?.data.update(object)
            }
        }
    }
    
    open func performFetch(pageNumber: Int) async throws { }
    
    public func fetch() async {
        do {
            if error != nil { error = nil }
            try await performFetch(pageNumber: 1)
            fetchedAt = .now
            currentPage = 1
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
    
    public func refetch() async {
        data.removeAll()
        fetchedAt = .distantPast
        
        await fetch()
    }
    
    public func fetchMoreContents() async {
        do {
            let nextPage = currentPage + 1
            try await performFetch(pageNumber: nextPage)
            fetchedAt = .now
            currentPage = nextPage
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
    
    public func needsUpdate(_ expiration: TimeInterval = 120) -> Bool {
        if invalidatedAt > fetchedAt { return true }
        else { return fetchedAt.hasExpired(in: expiration) }
    }
    
    public func invalidate() {
        invalidatedAt = .now
    }
}
