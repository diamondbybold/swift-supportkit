import SwiftUI
import SupportKit

public struct AsyncResourceView<T: APIModel, Content: View>: View {
    private let resource: APIResource<T>
    private let content: (AsyncResourceViewPhase) -> Content
    
    public init(_ resource: APIResource<T>,
                @ViewBuilder content: @escaping (AsyncResourceViewPhase) -> Content) {
        self.resource = resource
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            if let error = resource.error {
                content(.error(error))
            } else if resource.fetchedAt > .distantPast, resource.data == nil {
                content(.empty)
            } else if resource.fetchedAt == .distantPast {
                content(.loading)
            } else if let data = resource.data {
                content(.loaded(data))
            }
        }
    }
}

public enum AsyncResourceViewPhase {
    case loading
    case loaded(any APIModel)
    case empty
    case error(Error)
}
