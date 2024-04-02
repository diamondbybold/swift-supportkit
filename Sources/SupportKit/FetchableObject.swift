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
