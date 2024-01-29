import SwiftUI
import SupportKit

public struct AsyncView<Content: View>: View {
    private let fetchables: [any FetchableObject]
    private let content: (AsyncViewPhase) -> Content
    
    public init(_ fetchable: any FetchableObject,
                @ViewBuilder content: @escaping (AsyncViewPhase) -> Content) {
        self.fetchables = [fetchable]
        self.content = content
    }
    
    public init(_ fetchables: [any FetchableObject],
                @ViewBuilder content: @escaping (AsyncViewPhase) -> Content) {
        self.fetchables = fetchables
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            if fetchables.contains(where: { $0.isLoading }) {
                content(.loading)
            } else if let error = fetchables.first(where: { $0.loadingError != nil })?.loadingError {
                content(.error(error))
            } else if fetchables.contains(where: { $0.contentUnavailable }) {
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
