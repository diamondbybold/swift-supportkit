import SwiftUI
import SupportKit

public struct AsyncResourceView<T: APIModel, Content: View>: View {
    private let resource: APIResource<T>
    private let content: (AsyncViewPhase) -> Content
    
    public init(_ resource: APIResource<T>,
                @ViewBuilder content: @escaping (AsyncViewPhase) -> Content) {
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
            } else {
                content(.loaded)
            }
        }
    }
}
