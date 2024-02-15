import Foundation

@MainActor
public protocol FetchableObject: ObservableObject {
    var contentUnavailable: Bool { get }
    
    var lastUpdated: Date { get }
    var isLoading: Bool { get set }
    var loadingError: Error? { get set }
    
    func fetch(option: FetchOption?) async
}

public enum FetchOption {
    case expires(in: TimeInterval)
    case reload
    case refresh
}

extension FetchOption {
    public static var expiresIn1min: Self { .expires(in: 60) }
    public static var expiresIn2min: Self { .expires(in: 120) }
    public static var expiresIn5min: Self { .expires(in: 300) }
    public static var expiresIn10min: Self { .expires(in: 600) }
    public static var expiresIn15min: Self { .expires(in: 900) }
    public static var expiresIn30min: Self { .expires(in: 1800) }
    public static var expiresIn60min: Self { .expires(in: 3600) }
}

extension FetchableObject {
    public var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    public func refetch() { Task { await fetch(option: .reload) } }
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
    
    public func fetch(option: FetchOption? = nil) async {
        if case let .expires(in: interval) = option,
           loadingError == nil,
           !lastUpdated.hasExpired(in: interval) { return }
        
        if case .refresh = option { isLoading = false }
        else if case .reload = option { isLoading = true }
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
    
    public func fetch(option: FetchOption? = nil) async {
        if case let .expires(in: interval) = option,
           loadingError == nil,
           !lastUpdated.hasExpired(in: interval) { return }
        
        if case .refresh = option { isLoading = false }
        else if case .reload = option { isLoading = true }
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
    
    open func performFetch() async throws -> [T] { [] }
}
