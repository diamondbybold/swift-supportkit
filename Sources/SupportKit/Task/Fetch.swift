import Foundation

public enum FetchState {
    case waiting
    case empty
    case success(Info)
    case failure(any Error)
}

extension FetchState {
    public struct Info {
        public let date: Date = .now
        public let page: Int
        public let total: Int
        public let partial: Bool
    }
}

extension FetchState {
    public var isWaiting: Bool {
        if case .waiting = self { true }
        else { false }
    }
    
    public var isEmpty: Bool {
        if case .empty = self { true }
        else { false }
    }
    
    public var page: Int {
        if case let .success(info) = self { info.page }
        else { 1 }
    }
    
    public var total: Int {
        if case let .success(info) = self { info.total }
        else { 0 }
    }
    
    public var partial: Bool {
        if case let .success(info) = self { info.partial }
        else { false }
    }
    
    public var error: (any Error)? {
        if case let .failure(error) = self { error }
        else { nil }
    }
    
    public func needsUpdate(in interval: TimeInterval = 900) -> Bool {
        if case let .success(info) = self { info.date.hasExpired(in: interval) }
        else { true }
    }
}

extension Task where Success == Never, Failure == Never {
    @MainActor
    private static func prepareForFetch(_ state: inout FetchState,
                                        refreshing: Bool? = nil) {
        if let refreshing {
            if !refreshing { state = .waiting }
        } else {
            if state.error != nil || state.isEmpty || state.page > 1 { state = .waiting }
        }
    }
    
    @MainActor
    public static func fetch<T>(_ state: inout FetchState,
                                in store: inout T?,
                                refreshing: Bool? = nil,
                                task: () async throws -> T?) async {
        prepareForFetch(&state, refreshing: refreshing)
        
        do {
            store = try await task()
            state = .success(.init(page: 1, total: 1, partial: false))
        } catch is CancellationError {
        } catch {
            state = .failure(error)
        }
    }
    
    @MainActor
    public static func fetch<T>(_ state: inout FetchState,
                                in store: inout [T],
                                refreshing: Bool? = nil,
                                task: () async throws -> [T]) async {
        prepareForFetch(&state, refreshing: refreshing)
        
        do {
            store = try await task()
            state = .success(.init(page: 1, total: store.count, partial: false))
        } catch is CancellationError {
        } catch {
            state = .failure(error)
        }
    }
    
    @MainActor
    public static func fetch<T>(_ state: inout FetchState,
                                in store: inout [T],
                                refreshing: Bool? = nil,
                                task: (Int) async throws -> ([T], Int)) async {
        prepareForFetch(&state, refreshing: refreshing)
        
        do {
            let result = try await task(1)
            let count = result.0.count
            let total = result.1
            
            store = result.0
            state = .success(.init(page: 1, total: total, partial: count < total))
        } catch is CancellationError {
        } catch {
            state = .failure(error)
        }
    }
    
    @MainActor
    public static func fetchMore<T>(_ state: inout FetchState,
                                    in store: inout [T],
                                    task: (Int) async throws -> ([T], Int)) async {
        let nextPage = state.page + 1
        
        do {
            let result = try await task(nextPage)
            let count = result.0.count
            let total = result.1
            
            store.append(contentsOf: result.0)
            state = .success(.init(page: nextPage, total: total, partial: count < total))
        } catch is CancellationError {
        } catch {
            state = .failure(error)
        }
    }
}
