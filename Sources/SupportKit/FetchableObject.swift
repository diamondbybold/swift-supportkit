import Foundation

@MainActor
public protocol FetchableObject: ObservableObject {
    var contentUnavailable: Bool { get }
    
    var lastUpdated: Date { get }
    var isLoading: Bool { get set }
    var loadingError: Error? { get set }
    
    func fetch(refreshing: Bool?) async
}

extension FetchableObject {
    public var isRunningForPreviews: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    public func refetch() { Task { await fetch(refreshing: false) } }
    public func needsUpdate(in interval: TimeInterval = 900) -> Bool { lastUpdated.hasExpired(in: interval) }
}

// MARK: - Default concrete implementations
open class FetchableResource<T>: FetchableObject, Invalidatable {
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

open class FetchableCollection<T>: FetchableObject, Invalidatable {
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
    
    open func performFetch() async throws -> [T] { [] }
}
