import Foundation

public typealias APIResults<T> = (items: [T], count: Int)

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
    
    public override var contentUnavailable: Bool { collection.isEmpty }
    
    @Published public var total: Int = 0
    @Published public var currentPage: Int = 1
    public var pageSize: Int = 30
    public var hasMoreContent: Bool { collection.count < total }
    @Published public var moreContentError: Error? = nil
    
    public var nextPage: Int { currentPage + 1 }
    
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
    public func setPagedCollection(_ results: APIResults<T>) {
        collection = results.items
        total = results.count
        currentPage = 1
    }
    
    public func appendMoreContentToPagedCollection(_ results: APIResults<T>) {
        collection.append(contentsOf: results.items)
        currentPage += 1
    }
    
    public func appendMoreContentToPagedCollection(_ items: [T]) {
        collection.append(contentsOf: items)
        currentPage += 1
    }
}
