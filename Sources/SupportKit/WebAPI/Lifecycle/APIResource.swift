import Foundation

open class APIResource<T: APIModel>: FetchableObject, Invalidatable {
    @Published public var data: T? = nil
    
    public var contentUnavailable: Bool { data == nil }
    
    @Published public private(set) var lastUpdated: Date = .distantPast
    @Published public var isLoading: Bool = false
    @Published public var loadingError: Error? = nil
    
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
                if object.id == data?.id {
                    data = object
                }
            }
        }
    }
    
    public func fetch(refreshing: Bool? = nil) async {
        if let refreshing {
            isLoading = !refreshing
        } else {
            isLoading = loadingError != nil || contentUnavailable
        }
        
        loadingError = nil
        
        do {
            data = try await performFetch()
            lastUpdated = .now
        } catch is CancellationError {
        } catch {
            loadingError = error
        }
        
        isLoading = false
    }
    
    open func performFetch() async throws -> T? { nil }
}
