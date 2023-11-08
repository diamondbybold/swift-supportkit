import Foundation

@MainActor
open class Store: ObservableObject, Invalidatable {
    @Published public var state: State = .initial
    
    deinit { untracking() }
    
    public init() {
        tracking { [weak self] in
            for await _ in Self.invalidates {
                self?.state = .invalidated
            }
        }
    }
}

extension Store {
    public enum State {
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
}
