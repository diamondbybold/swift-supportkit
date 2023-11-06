import Foundation

@MainActor
public class APIStore<T: APIModel>: ObservableObject, Invalidatable {
    @Published public var state: APIStoreState = .initial
    
    public var resource: T? {
        get { collection.first }
        set {
            if let newValue {
                collection = [newValue]
            } else {
                collection = []
            }
        }
    }
    
    public var collection: [T] = [] {
        willSet { objectWillChange.send() }
        didSet { state = .updated(Date.now) }
    }
    
    public var contentUnavailable: Bool { collection.isEmpty }
    
    @Published public var total: Int = 0
    @Published public var currentPage: Int = 1
    public var pageSize: Int = 30
    public var hasMoreContent: Bool { collection.count < total }
    
    deinit { untracking() }
    
    public init() {
        tracking { [weak self] in
            for await _ in Self.invalidates {
                self?.state = .invalidated
            }
        }
        
        tracking { [weak self] in
            await self?.collection.handleUpdates()
        }
    }
    
    public convenience init(resource: T) {
        self.init()
        self.resource = resource
    }
    
    public convenience init(resources: [T]) {
        self.init()
        self.collection = collection
    }
}

public enum APIStoreState {
    case initial
    case updating
    case updated(Date)
    case invalidated
    case error(Error)
    case moreContentError(Error)
    
    public func needsUpdate(_ expiration: TimeInterval = 120) -> Bool {
        switch self {
        case .initial, .invalidated:
            return true
        case let .updated(date):
            return date.hasExpired(in: expiration)
        default:
            return false
        }
    }
    
    public var isUpdating: Bool {
        if case .updating = self {
            return true
        } else {
            return false
        }
    }
    
    public var isInvalidated: Bool {
        if case .invalidated = self {
            return true
        } else {
            return false
        }
    }
    
    public var error: Error? {
        if case let .error(e) = self {
            return e
        } else {
            return nil
        }
    }
    
    public var moreContentError: Error? {
        if case let .moreContentError(e) = self {
            return e
        } else {
            return nil
        }
    }
}
