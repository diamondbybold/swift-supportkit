import Foundation

open class APIPagedCollection<T: APIModel>: FetchableObject, Invalidatable, Refreshable {
    @Published public var data: [T] = []
    
    @Published public var total: Int = 0
    @Published public private(set) var currentPage: Int = 1
    
    public var contentUnavailable: Bool { data.isEmpty }
    public var hasMoreContent: Bool { data.count < total }
    
    @Published public private(set) var lastUpdated: Date = .distantPast
    @Published public var isLoading: Bool = false
    @Published public var loadingError: Error? = nil
    
    package var isRefreshing: Bool = false
    
    deinit { untracking() }
    
    public init() {
        tracking { [weak self] in
            guard let self else { return }
            
            for await _ in Self.invalidates.map({ $0.object }) {
                await fetch()
            }
        }
        
        tracking { [weak self] in
            guard let self else { return }
            
            for await object in T.updates.compactMap({ $0.object as? T }) {
                data.update(object)
            }
        }
    }
    
    public func fetch(option: FetchOption? = nil) async {
        if case let .ifExpired(interval) = option,
           loadingError == nil,
           !lastUpdated.hasExpired(in: interval) { return }
        
        if case .refresh = option { isLoading = false }
        else { isLoading = loadingError != nil || contentUnavailable || currentPage > 1 }
        
        loadingError = nil
        
        do {
            let res = try await performFetch(page: 1)
            data = res.elements
            total = res.total
            
            lastUpdated = .now
            currentPage = 1
        } catch is CancellationError {
        } catch {
            loadingError = error
        }
        
        isLoading = false
    }
    
    public func fetchMoreContents() async {
        do {
            let nextPage = currentPage + 1
            
            let res = try await performFetch(page: nextPage)
            data += res.elements
            
            lastUpdated = .now
            currentPage = nextPage
        } catch is CancellationError {
        } catch {
            self.loadingError = error
        }
    }
    
    open func performFetch(page: Int) async throws -> APIResults<T> { (elements: [], total: 0) }
}
