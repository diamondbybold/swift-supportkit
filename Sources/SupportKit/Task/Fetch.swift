import Foundation

public enum Fetch {
    case waiting
    case empty
    case success(Info)
    case failure(any Error)
}

extension Fetch {
    public struct Info {
        public let date: Date = .now
        public let page: Int
        public let total: Int
        public let partial: Bool
    }
}

extension Fetch {
    public var isEmpty: Bool {
        if case .empty = self { true }
        else { false }
    }
    
    public func needsUpdate(in interval: TimeInterval = 900) -> Bool {
        if case let .success(info) = self { info.date.hasExpired(in: interval) }
        else { true }
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
}

extension Fetch {
    private mutating func prepare(refreshing: Bool? = nil) {
        if let refreshing {
            if !refreshing { self = .waiting }
        } else {
            if error != nil || isEmpty || page > 1 { self = .waiting }
        }
    }
    
    public mutating func perform<T>(in store: inout T?, refreshing: Bool? = nil, _ task: () async throws -> T?) async {
        prepare(refreshing: refreshing)
        
        do {
            store = try await task()
            self = .success(.init(page: 1, total: 1, partial: false))
        } catch is CancellationError {
        } catch {
            self = .failure(error)
        }
    }
    
    public mutating func perform<T>(in store: inout [T], refreshing: Bool? = nil, _ task: () async throws -> [T]) async {
        prepare(refreshing: refreshing)
        
        do {
            store = try await task()
            self = .success(.init(page: 1, total: store.count, partial: false))
        } catch is CancellationError {
        } catch {
            self = .failure(error)
        }
    }
    
    public mutating func perform<T>(in store: inout [T], refreshing: Bool? = nil, _ task: (Int) async throws -> ([T], Int)) async {
        prepare(refreshing: refreshing)
        
        do {
            let result = try await task(1)
            let count = result.0.count
            let total = result.1
            
            store = result.0
            self = .success(.init(page: 1, total: total, partial: count < total))
        } catch is CancellationError {
        } catch {
            self = .failure(error)
        }
    }
    
    public mutating func next<T>(in store: inout [T], _ task: (Int) async throws -> ([T], Int)) async {
        let nextPage = page + 1
        
        do {
            let result = try await task(nextPage)
            let count = result.0.count
            let total = result.1
            
            store.append(contentsOf: result.0)
            self = .success(.init(page: nextPage, total: total, partial: count < total))
        } catch is CancellationError {
        } catch {
            self = .failure(error)
        }
    }
}
