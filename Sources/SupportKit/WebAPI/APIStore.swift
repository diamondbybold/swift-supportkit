import Foundation

open class APIStore<T: APIModel>: Store {
    public var resource: T? {
        get { collection.first }
        set {
            if let newValue {
                collection = [newValue]
            } else {
                collection = []
            }
        }
    }
    
    @Published public var collection: [T] = []
    
    public override var contentUnavailable: Bool { fetchedAt > .distantPast && collection.isEmpty }
    
    @Published public var total: Int = 0
    @Published public var currentPage: Int = 1
    public var pageSize: Int = 30
    public var hasMoreContent: Bool { collection.count < total }
    @Published public var moreContentError: Error? = nil
    
    public override init() {
        super.init()
        
        tracking { [weak self] in
            for await object in T.updates.compactMap({ $0.object as? T }) {
                self?.collection.update(object)
            }
        }
    }
    
    public convenience init(resource: T) {
        self.init()
        self.resource = resource
    }
    
    public convenience init(resources: [T]) {
        self.init()
        self.collection = collection
    }
}

extension APIStore {
    public func setPagedCollection(_ data: (items: [T], count: Int)) {
        collection = data.items
        total = data.count
        currentPage = 1
    }
    
    public func appendMoreContentToPagedCollection(_ items: [T]) {
        collection.append(contentsOf: items)
        currentPage += 1
    }
}
