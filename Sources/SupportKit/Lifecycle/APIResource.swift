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
    
    public func fetch(option: FetchOption? = nil) async {
        if case let .expires(in: interval) = option,
           loadingError == nil,
           !lastUpdated.hasExpired(in: interval) { return }
        
        if case .refresh = option { isLoading = false }
        else { isLoading = loadingError != nil || contentUnavailable }
        
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
