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
    
    public var collection: [T] = [] {
        willSet { objectWillChange.send() }
        didSet { lastUpdate = .now }
    }
    
    public var contentUnavailable: Bool { collection.isEmpty }
    
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
