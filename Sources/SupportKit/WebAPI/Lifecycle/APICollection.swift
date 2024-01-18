import Foundation

open class APICollection<T: APIModel>: Fetchable, Invalidatable {
    @Published public var data: [T] = []
    @Published public var error: Error? = nil
        
    @Published public var total: Int = 0
    @Published public private(set) var currentPage: Int = 1
    
    public var contentUnavailable: Bool { data.isEmpty }
    public var hasMoreContent: Bool { data.count < total }
    
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
                self?.data.update(object)
            }
        }
    }
    
    open func performFetch(pageNumber: Int) async throws -> APIResults<T> { (items: [], count: 0) }
    
    public func fetch() async {
        do {
            if error != nil { error = nil }
            
            let res = try await performFetch(pageNumber: 1)
            data = res.items
            total = res.count
            
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
            
            let res = try await performFetch(pageNumber: nextPage)
            data += res.items
            
            fetchedAt = .now
            currentPage = nextPage
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
}
