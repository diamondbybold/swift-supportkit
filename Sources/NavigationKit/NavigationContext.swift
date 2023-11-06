import SwiftUI

@MainActor
public class NavigationContext: ObservableObject {
    @Published var path: [Data] = []
    @Published var sheet: Data? = nil
    @Published var fullScreenCover: Data? = nil
    
    var onDismiss: (Bool) -> Void = { _ in }
    
    public func destination(_ route: any NavigationRoute) { path.append(Data(route)) }
    public func sheet(_ route: any NavigationRoute) { fullScreenCover = nil; sheet = Data(route) }
    public func fullScreenCover(_ route: any NavigationRoute) { sheet = nil; fullScreenCover = Data(route) }
    
    public func dismiss(withConfirmation: Bool = false) { onDismiss(withConfirmation) }
}

// MARK: - Destination Routes
extension NavigationContext {
    public var destinationRoutes: [any NavigationRoute] { path.map { $0.route } }
    
    public func replaceDestinationRoutesWith(_ routes: [any NavigationRoute]) { path = routes.map { Data($0) } }
    public func removeAllDestinationRoutes() { path.removeAll() }
    public func removeLastDestinationRoute(_ k: Int = 1) { path.removeLast(k) }
}

// MARK: - Support Types
extension NavigationContext {
    struct Data: Identifiable, Hashable {
        let id = UUID()
        let route: any NavigationRoute
        
        init(_ route: any NavigationRoute) { self.route = route }
        
        static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }
}

public protocol NavigationRoute {
    associatedtype V: View
    
    @ViewBuilder
    var view: V { get }
}
