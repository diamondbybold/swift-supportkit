import Foundation
import Combine

public class Store<T: Identifiable>: FetchableObject {
    public var fetchRequest: FetchRequest? = nil
    
    @Published public var elements: [T] = []
    @Published public var total: Int = 0
    
    @Published public private(set) var currentPage: Int = 1
    
    public var singleElement: T? { elements.first }
    
    public var contentUnavailable: Bool { elements.isEmpty }
    public var hasMoreContent: Bool { elements.count < total }
    
    @Published public private(set) var lastUpdated: Date = .distantPast
    @Published public var isLoading: Bool = false
    @Published public var loadingError: Error? = nil
    
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
    
    public init(_ name: String = "") {
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
                   let storeName = notification.userInfo?["storeName"] as? String,
                   storeName == name {
                    self?.elements.append(element)
                }
            }
        }
        
        elementRemovedFromStoreTask = Task { [weak self] in
            let notifications = NotificationCenter.default.notifications(named: .elementRemovedFromStore)
            for await notification in notifications {
                if let element = notification.object as? T,
                   let storeName = notification.userInfo?["storeName"] as? String,
                   storeName == name {
                    self?.elements.remove(element)
                }
            }
        }
    }
    
    public func fetch(_ fetchRequest: FetchRequest, option: FetchOption? = nil) async {
        self.fetchRequest = fetchRequest
        await fetch(option: option)
    }
    
    public func fetch(option: FetchOption? = nil) async {
        guard let fetchRequest else { return }
        
        if case .reload = option { isLoading = true }
        else if case .refresh = option { isLoading = false }
        else { isLoading = loadingError != nil || contentUnavailable || currentPage > 1 }
        
        loadingError = nil
        
        do {
            let res = try await fetchRequest.performFetch(page: 1, preview: isPreview)
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
            
            let res = try await fetchRequest.performFetch(page: nextPage, preview: isPreview)
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
    open class FetchRequest: ObservableObject {
        public init() { }
        open func performFetch(page: Int, preview: Bool) async throws -> (elements: [T], total: Int?) { ([], nil) }
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
    public static func add(_ element: T, to name: String = "") {
        NotificationCenter.default.post(name: .elementAddedToStore,
                                        object: element,
                                        userInfo: ["storeName" : name])
    }
    
    @MainActor
    public static func remove(_ element: T, from name: String = "") {
        NotificationCenter.default.post(name: .elementRemovedFromStore,
                                        object: element,
                                        userInfo: ["storeName" : name])
    }
}

extension ObservableObject {
    @MainActor
    fileprivate func sendObjectWillChange() { (objectWillChange as? ObservableObjectPublisher)?.send() }
}
