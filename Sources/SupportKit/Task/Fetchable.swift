import Foundation

@MainActor
public protocol Fetchable: ObservableObject, ObserverObject {
    var isFetching: Bool { get set }
    var error: Error? { get set }
    var contentUnavailable: Bool { get }
    
    var fetchedAt: Date { get set }
    var invalidatedAt: Date { get set }
    
    func fetch() async
    func refetch() async
    
    func needsUpdate(_ expiration: TimeInterval) -> Bool
    func invalidate(refetch: Bool)
}

extension Fetchable {
    public var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    public func needsUpdate(_ expiration: TimeInterval = 900) -> Bool {
        if invalidatedAt > fetchedAt { return true }
        else { return fetchedAt.hasExpired(in: expiration) }
    }
    
    public func invalidate(refetch: Bool = false) {
        if refetch { fetchedAt = .distantPast }
        invalidatedAt = .now
    }
}

public class AnyFetchable<T>: Fetchable, Invalidatable {
    @Published public var data: [T] = []
    
    public var contentUnavailable: Bool { data.isEmpty }
    
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
    }
    
    open func performFetch() async throws -> [T] { [] }
    
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
        data.removeAll()
        fetchedAt = .distantPast
        
        await fetch()
    }
}
