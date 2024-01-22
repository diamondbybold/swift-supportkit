import SwiftUI
import SupportKit

public struct AsyncView<T: Fetchable, Content: View>: View {
    private let fetchable: T
    private let alwaysShowFetchIndicator: Bool
    private let content: (AsyncViewPhase) -> Content
    
    public init(_ fetchable: T,
                alwaysShowFetchIndicator: Bool = false,
                @ViewBuilder content: @escaping (AsyncViewPhase) -> Content) {
        self.fetchable = fetchable
        self.alwaysShowFetchIndicator = alwaysShowFetchIndicator
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            if fetchable.isFetching && (alwaysShowFetchIndicator || fetchable.fetchedAt == .distantPast) {
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

public enum AsyncViewPhase {
    case loading
    case loaded
    case empty
    case error(Error)
}
