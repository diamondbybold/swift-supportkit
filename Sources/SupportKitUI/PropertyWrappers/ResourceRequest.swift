import SwiftUI
import SupportKit

@propertyWrapper
public struct ResourceRequest<T: Sendable>: DynamicProperty, FetchableObject {
    @State public var wrappedValue: T?
    
    public var contentUnavailable: Bool { wrappedValue == nil }
    
    @State public private(set) var lastUpdated: Date = .distantPast
    @State public var isLoading: Bool = false
    @State public var loadingError: (any Error)? = nil
    
    @State private var task: () async throws -> T? = { nil }
    
    public init(wrappedValue defaultValue: T? = nil) {
        _wrappedValue = State(initialValue: defaultValue)
    }
    
    public func fetch(refreshing: Bool? = nil, _ task: @escaping () async throws -> T?) async {
        self.task = task
        await fetch(refreshing: refreshing)
    }
    
    public func fetch(refreshing: Bool? = nil) async {
        if let refreshing {
            isLoading = !refreshing
        } else {
            isLoading = loadingError != nil || contentUnavailable
        }
        
        loadingError = nil
        
        do {
            wrappedValue = try await task()
            lastUpdated = .now
        } catch is CancellationError {
        } catch {
            loadingError = error
        }
        
        isLoading = false
    }
}
