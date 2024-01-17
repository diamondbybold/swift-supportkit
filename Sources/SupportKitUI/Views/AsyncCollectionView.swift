import SwiftUI
import SupportKit

public struct AsyncCollectionView<T: APIModel, Content: View>: View {
    private let collection: APICollection<T>
    private let content: (AsyncCollectionViewPhase) -> Content
    
    public init(_ collection: APICollection<T>,
                @ViewBuilder content: @escaping (AsyncCollectionViewPhase) -> Content) {
        self.collection = collection
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            if let error = collection.error {
                content(.error(error))
            } else if collection.fetchedAt > .distantPast, collection.data.isEmpty {
                content(.empty)
            } else if collection.fetchedAt == .distantPast {
                content(.loading)
            } else {
                content(.loaded(collection.data))
            }
        }
    }
}

public enum AsyncCollectionViewPhase {
    case loading
    case loaded([any APIModel])
    case empty
    case error(Error)
}
