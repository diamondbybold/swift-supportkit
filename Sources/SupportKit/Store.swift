import Foundation

public class Store<T: Identifiable>: FetchableObject, ObservableObject {
    public var fetchRequest: FetchRequest? = nil
    
    @Published public var elements: [T] = []
    @Published public var total: Int = 0
    
    @Published public private(set) var currentPage: Int = 1
    
    public var singleElement: T? { elements.first }
    
    public var contentUnavailable: Bool { elements.isEmpty }
    public var hasMoreContent: Bool { elements.count < total }
    
    @Published public private(set) var lastUpdated: Date = .distantPast
    @Published public var isLoading: Bool = false
    @Published public var loadingError: (any Error)? = nil
    
    private var storeDidChangeTask: Task<Void, Never>? = nil
    private var elementInStoreDidChangeTask: Task<Void, Never>? = nil
    private var elementsInStoreDidChangeTask: Task<Void, Never>? = nil
    private var elementAddedToStoreTask: Task<Void, Never>? = nil
    private var elementRemovedFromStoreTask: Task<Void, Never>? = nil
    
    deinit {
        storeDidChangeTask?.cancel()
        elementInStoreDidChangeTask?.cancel()
        elementsInStoreDidChangeTask?.cancel()
        elementAddedToStoreTask?.cancel()
        elementRemovedFromStoreTask?.cancel()
    }
    
    public init(_ tag: String = "") {
        storeDidChangeTask = Task { [weak self] in
            let notifications = NotificationCenter.default.notifications(named: .storeDidChange)
            for await notification in notifications {
                if notification.object is Self.Type {
                    await self?.fetch()
                }
            }
        }
        
        elementInStoreDidChangeTask = Task { [weak self] in
            let notifications = NotificationCenter.default.notifications(named: .elementInStoreDidChange)
            for await notification in notifications {
                if let element = notification.object as? T {
                    if let observableElement = element as? (any ObservableObject) {
                        observableElement.sendObjectWillChange()
                    }
                    self?.elements.update(element)
                }
            }
        }
        
        elementsInStoreDidChangeTask = Task { [weak self] in
            let notifications = NotificationCenter.default.notifications(named: .elementsInStoreDidChange)
            for await notification in notifications {
                if let handler = notification.object as? (T) -> Void {
                    for element in self?.elements ?? [] {
                        if let observableElement = element as? (any ObservableObject) {
                            observableElement.sendObjectWillChange()
                        }
                        handler(element)
                    }
                }
            }
        }
        
        elementAddedToStoreTask = Task { [weak self] in
            let notifications = NotificationCenter.default.notifications(named: .elementAddedToStore)
            for await notification in notifications {
                if let element = notification.object as? T,
                   let notificationTag = notification.userInfo?["tag"] as? String,
                   notificationTag == tag {
                    self?.elements.append(element)
                    self?.total += 1
                }
            }
        }
        
        elementRemovedFromStoreTask = Task { [weak self] in
            let notifications = NotificationCenter.default.notifications(named: .elementRemovedFromStore)
            for await notification in notifications {
                if let element = notification.object as? T,
                   let notificationTag = notification.userInfo?["tag"] as? String,
                   notificationTag == tag {
                    self?.elements.remove(element)
                    self?.total -= 1
                }
            }
        }
    }
    
    public func fetch(_ fetchRequest: FetchRequest, refreshing: Bool? = nil) async {
        self.fetchRequest = fetchRequest
        await fetch(refreshing: refreshing)
    }
    
    public func fetch(refreshing: Bool? = nil, _ task: @escaping (Int) async throws -> ([T], Int?)) async {
        self.fetchRequest = .init { try await task($0) }
        await fetch(refreshing: refreshing)
    }
    
    public func fetch(refreshing: Bool? = nil, _ task: @escaping () async throws -> [T]) async {
        self.fetchRequest = .init { _ in
            let r = try await task()
            return (r, nil)
        }
        await fetch(refreshing: refreshing)
    }
    
    public func fetch(refreshing: Bool? = nil, _ task: @escaping () async throws -> T?) async {
        self.fetchRequest = .init { _ in
            if let r = try await task() {
                return ([r], nil)
            } else {
                return ([], nil)
            }
        }
        await fetch(refreshing: refreshing)
    }
    
    public func fetch(refreshing: Bool? = nil) async {
        guard let fetchRequest else { return }
        
        if let refreshing {
            isLoading = !refreshing
        } else {
            isLoading = loadingError != nil || contentUnavailable || currentPage > 1
        }
        
        loadingError = nil
        
        do {
            let res = try await fetchRequest(page: 1)
            elements = res.elements
            total = res.total ?? elements.count
            
            lastUpdated = .now
            currentPage = 1
        } catch is CancellationError {
        } catch {
            loadingError = error
        }
        
        isLoading = false
    }
    
    public func fetchMoreContents() async {
        guard let fetchRequest else { return }
        
        do {
            let nextPage = currentPage + 1
            
            let res = try await fetchRequest(page: nextPage)
            elements += res.elements
            
            lastUpdated = .now
            currentPage = nextPage
        } catch is CancellationError {
        } catch {
            self.loadingError = error
        }
    }
}

// MARK: - Support Types
extension Store {
    public struct FetchRequest {
        public typealias Result = (elements: [T], total: Int?)
        public typealias Task = (Int) async throws -> Result
        
        private let task: Task
        
        public init(_ task: @escaping Task) { self.task = task }
        
        public func callAsFunction(page: Int) async throws -> Result { try await task(page) }
    }
}

// MARK: - Notifications
extension Notification.Name {
    public static let storeDidChange = Notification.Name("StoreDidChangeNotification")
    public static let elementInStoreDidChange = Notification.Name("ElementInStoreDidChangeNotification")
    public static let elementsInStoreDidChange = Notification.Name("ElementsInStoreDidChangeNotification")
    public static let elementAddedToStore = Notification.Name("ElementAddedToStoreNotification")
    public static let elementRemovedFromStore = Notification.Name("ElementRemovedFromStoreNotification")
}

extension Store {
    @MainActor
    public static func invalidate() {
        NotificationCenter.default.post(name: .storeDidChange,
                                        object: Self.self)
    }
    
    @MainActor
    public static func update(_ element: T) {
        NotificationCenter.default.post(name: .elementInStoreDidChange,
                                        object: element)
    }
    
    @MainActor
    public static func updateAll(_ handler: @escaping (T) -> Void) {
        NotificationCenter.default.post(name: .elementsInStoreDidChange,
                                        object: handler)
    }
    
    @MainActor
    public static func add(_ element: T, to tag: String = "") {
        NotificationCenter.default.post(name: .elementAddedToStore,
                                        object: element,
                                        userInfo: ["tag" : tag])
    }
    
    @MainActor
    public static func remove(_ element: T, from tag: String = "") {
        NotificationCenter.default.post(name: .elementRemovedFromStore,
                                        object: element,
                                        userInfo: ["tag" : tag])
    }
}
