import SwiftUI

@MainActor
public class NavigationContext: ObservableObject {
    @Published var path: [DestinationData] = []
    @Published var sheet: DestinationData? = nil
    @Published var fullScreenCover: DestinationData? = nil
    @Published var confirmation: ActionConfirmation? = nil
    
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
    
    public func confirmation(_ confirmation: ActionConfirmation) { self.confirmation = confirmation }
    
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

// MARK: - Confirmation
public struct ActionConfirmation {
    public let title: LocalizedStringKey
    public let message: LocalizedStringKey?
    public let actionLabel: LocalizedStringKey
    public let actionRole: ButtonRole?
    public let action: () -> Void
    
    public init(title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                actionRole: ButtonRole? = nil,
                action: @escaping () -> Void = { }) {
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.actionRole = actionRole
        self.action = action
    }
}
