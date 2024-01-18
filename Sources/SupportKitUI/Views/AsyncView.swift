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
            if let error = fetchable.error {
                content(.error(error, { fetchable.invalidate(refetch: true) }))
            } else if fetchable.fetchedAt > .distantPast, fetchable.contentUnavailable {
                content(.empty({ fetchable.invalidate(refetch: true) }))
            } else if fetchable.fetchedAt == .distantPast {
                content(.loading)
            } else {
                content(.loaded)
            }
        }
    }
}

public enum AsyncViewPhase {
    case loading
    case loaded
    case empty(() -> Void)
    case error(Error, () -> Void)
}
