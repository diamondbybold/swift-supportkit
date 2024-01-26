import SwiftUI
import SupportKit

public struct AsyncView<T: Fetchable, Content: View>: View {
    private let fetchable: T
    private let content: (AsyncViewPhase) -> Content
    
    public init(_ fetchable: T,
                @ViewBuilder content: @escaping (AsyncViewPhase) -> Content) {
        self.fetchable = fetchable
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            if fetchable.isFetching, fetchable.fetchedAt == .distantPast {
                content(.loading)
            } else if let error = fetchable.error {
                content(.error(error))
            } else if fetchable.contentUnavailable {
                content(.empty)
            } else {
                content(.loaded)
            }
        }
    }
}

public struct AsyncGroupView<Content: View>: View {
    private let fetchables: [any Fetchable]
    private let content: (AsyncViewPhase) -> Content
    
    public init(_ fetchables: [any Fetchable],
                @ViewBuilder content: @escaping (AsyncViewPhase) -> Content) {
        self.fetchables = fetchables
        self.content = content
    }
    
    @MainActor
    private var showFetchIndicator: Bool { fetchables.contains { $0.isFetching } && fetchables.contains { $0.fetchedAt == .distantPast } }
    
    @MainActor
    private var anyError: Error? { fetchables.first { $0.error != nil }?.error }
    
    @MainActor
    private var anyContentUnavailable: Bool { fetchables.contains { $0.contentUnavailable } }
    
    public var body: some View {
        ZStack {
            if showFetchIndicator {
                content(.loading)
            } else if let error = anyError {
                content(.error(error))
            } else if anyContentUnavailable {
                content(.empty)
            } else {
                content(.loaded)
            }
        }
    }
}

public enum AsyncViewPhase {
    case loading
    case loaded
    case empty
    case error(Error)
}
