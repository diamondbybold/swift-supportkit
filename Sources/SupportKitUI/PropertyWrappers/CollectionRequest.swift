import SwiftUI
import SupportKit

@propertyWrapper
public struct CollectionRequest<T>: DynamicProperty, FetchableObject {
    @State public var wrappedValue: [T]
    
    @State public var total: Int = 0
    @State public private(set) var currentPage: Int = 1
    
    public var contentUnavailable: Bool { wrappedValue.isEmpty }
    public var hasMoreContent: Bool { wrappedValue.count < total }
    
    @State public private(set) var lastUpdated: Date = .distantPast
    @State public var isLoading: Bool = false
    @State public var loadingError: (any Error)? = nil
    
    @State private var task: (Int) async throws -> ([T], Int) = { _ in ([], 0)}
    
    public init(wrappedValue defaultValue: [T] = []) {
        _wrappedValue = State(initialValue: defaultValue)
    }
    
    public func fetch(refreshing: Bool? = nil, _ task: @escaping (Int) async throws -> ([T], Int)) async {
        self.task = task
        await fetch(refreshing: refreshing)
    }
    
    public func fetch(refreshing: Bool? = nil, _ task: @escaping () async throws -> [T]) async {
        self.task = { _ in
            let r = try await task()
            return (r, r.count)
        }
        await fetch(refreshing: refreshing)
    }
    
    public func fetch(refreshing: Bool? = nil) async {
        if let refreshing {
            isLoading = !refreshing
        } else {
            isLoading = loadingError != nil || contentUnavailable || currentPage > 1
        }
        
        loadingError = nil
        
        do {
            let res = try await task(1)
            wrappedValue = res.0
            total = res.1
            
            lastUpdated = .now
            currentPage = 1
        } catch is CancellationError {
        } catch {
            loadingError = error
        }
        
        isLoading = false
    }
    
    public func fetchMoreContents() async {
        do {
            let nextPage = currentPage + 1
            
            let res = try await task(nextPage)
            wrappedValue += res.0
            
            lastUpdated = .now
            currentPage = nextPage
        } catch is CancellationError {
        } catch {
            self.loadingError = error
        }
    }
}
