import Foundation

open class APICollection<T: APIModel>: Fetchable, Invalidatable {
    @Published public var data: [T] = []
    
    @Published public var total: Int = 0
    @Published public private(set) var currentPage: Int = 1
    
    public var contentUnavailable: Bool { data.isEmpty }
    public var hasMoreContent: Bool { data.count < total }
    
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
                self?.data.update(object)
            }
        }
    }
    
    open func performFetch(page: Int) async throws -> APIResults<T> { (elements: [], total: 0) }
    
    public func fetch() async {
        if isPreview {
            let previews = T.previews
            data = previews
            total = previews.count
            fetchedAt = .now
            currentPage = 1
            return
        }
        
        do {
            isFetching = true
            
            let res = try await performFetch(page: 1)
            data = res.elements
            total = res.total
            
            fetchedAt = .now
            currentPage = 1
            
            isFetching = false
            error = nil
        } catch is CancellationError {
            isFetching = false
        } catch {
            isFetching = false
            self.error = error
        }
    }
    
    public func refetch() {
        data.removeAll()
        total = 0
        fetchedAt = .distantPast
        
        Task {
            await fetch()
        }
    }
    
    public func fetchMoreContents() async {
        do {
            let nextPage = currentPage + 1
            
            let res = try await performFetch(page: nextPage)
            data += res.elements
            
            fetchedAt = .now
            currentPage = nextPage
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
}
