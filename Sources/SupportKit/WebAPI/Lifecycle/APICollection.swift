import Foundation

open class APICollection<T: APIModel>: FetchableObject, Invalidatable {
    @Published public var data: [T] = []
    
    public var contentUnavailable: Bool { data.isEmpty }
    
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
                data.update(object)
            }
        }
    }
    
    public func fetch() async {
        do {
            isLoading = loadingError != nil || contentUnavailable
            data = try await performFetch()
            lastUpdated = .now
            isLoading = false
            loadingError = nil
        } catch is CancellationError {
            isLoading = false
        } catch {
            isLoading = false
            loadingError = error
        }
    }
    
    open func performFetch() async throws -> [T] { [] }
}
