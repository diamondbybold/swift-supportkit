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
    
    public func tryAgain() { Task { await fetch(option: nil) } }
}
