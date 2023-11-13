import SwiftUI

@MainActor
public class NavigationContext: ObservableObject {
    @Published var path: [DestinationData] = []
    @Published var sheet: DestinationData? = nil
    @Published var fullScreenCover: DestinationData? = nil
    
    var onDismiss: (Bool) -> Void = { _ in }
    
    public func destination(_ destination: Destination,
                            @ViewBuilder content: @escaping () -> any View) { 
        switch destination {
        case .stack:
            path.append(DestinationData(content: content))
        case .sheet:
            fullScreenCover = nil
            sheet = DestinationData(content: content)
        case .fullScreenCover:
            sheet = nil
            fullScreenCover = DestinationData(content: content)
        }
    }
    
    public func dismiss(withConfirmation: Bool = false) { onDismiss(withConfirmation) }
}

// MARK: - Stack Management
extension NavigationContext {
    public var destinationCountInStack: Int { path.count }
    public func removeAllDestinationsInStack() { path.removeAll() }
    public func removeLastDestinationInStack(_ k: Int = 1) { path.removeLast(k) }
}

// MARK: - Support Types
extension NavigationContext {
    public enum Destination {
        case stack
        case sheet
        case fullScreenCover
    }
    
    struct DestinationData: Identifiable, Hashable {
        let id = UUID()
        let content: () -> any View
        
        static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }
}