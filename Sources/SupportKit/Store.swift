import Foundation

public class Store<T: Identifiable>: FetchableObject {
    @Published public var fetchRequest: AnyFetchRequest? = nil
    
    @Published public var elements: [T] = []
    @Published public var total: Int = 0
    
    @Published public private(set) var currentPage: Int = 1
    
    public var singleElement: T? { elements.first }
    
    public var contentUnavailable: Bool { elements.isEmpty }
    public var hasMoreContent: Bool { elements.count < total }
    
    @Published public private(set) var lastUpdated: Date = .distantPast
    @Published public var isLoading: Bool = false
    @Published public var loadingError: Error? = nil
    
    deinit { untracking() }
    
    public init() {
        tracking { [weak self] in
            guard let self else { return }
            
            let storeDidChangeNotifications = NotificationCenter.default.notifications(named: .storeDidChange)
            for await notification in storeDidChangeNotifications {
                if notification.object is Self {
                    await fetch()
                }
            }
        }
        
        tracking { [weak self] in
            guard let self else { return }
            
            let elementInStoreDidChangeNotifications = NotificationCenter.default.notifications(named: .elementInStoreDidChange)
            for await notification in elementInStoreDidChangeNotifications {
                if let element = notification.object as? T {
                    elements.update(element)
                }
            }
        }
    }
    
    public func fetch(_ fetchRequest: AnyFetchRequest, option: FetchOption? = nil) async {
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
            let res = try await fetchRequest.performFetch(page: 1)
            elements = res.elements as? [T] ?? []
            total = res.total
            
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
            
            let res = try await fetchRequest.performFetch(page: nextPage)
            elements += res.elements as? [T] ?? []
            
            lastUpdated = .now
            currentPage = nextPage
        } catch is CancellationError {
        } catch {
            self.loadingError = error
        }
    }
}

// MARK: - Notifications
extension Notification.Name {
    public static let storeDidChange = Notification.Name("StoreDidChangeNotification")
    public static let elementInStoreDidChange = Notification.Name("ElementInStoreDidChangeNotification")
    
    public static let elementAddedToStore = Notification.Name("ElementAddedToStoreNotification")
    public static let elementRemovedFromStore = Notification.Name("ElementRemovedFromStoreNotification")
}

// MARK: - FetchRequest
public protocol AnyFetchRequest {
    func performFetch(page: Int) async throws -> (elements: [Any], total: Int)
}

extension AnyFetchRequest {
    public var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
}
