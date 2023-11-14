import SwiftUI

@MainActor
public class NavigationContext: ObservableObject {
    @Published var path: [DestinationData] = []
    @Published var sheet: DestinationData? = nil
    @Published var fullScreenCover: DestinationData? = nil
    
    @Published var confirmation: Confirmation? = nil
    @Published var alert: Alert? = nil
    
    var onDismiss: () -> Void = { }
    
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
    
    public func confirmation(title: LocalizedStringKey,
                             message: LocalizedStringKey? = nil,
                             actionLabel: LocalizedStringKey,
                             actionRole: ButtonRole? = nil,
                             action: @escaping () -> Void) {
        self.confirmation = .init(title: title,
                                  message: message,
                                  actionLabel: actionLabel,
                                  actionRole: actionRole,
                                  action: action)
    }
    
    public func alert(title: LocalizedStringKey,
                      message: LocalizedStringKey? = nil) {
        self.alert = .init(title: title,
                           message: message)
    }
    
    public func dismiss() { onDismiss() }
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
    
    struct Confirmation {
        let title: LocalizedStringKey
        let message: LocalizedStringKey?
        let actionLabel: LocalizedStringKey
        let actionRole: ButtonRole?
        let action: () -> Void
    }
    
    struct Alert {
        let title: LocalizedStringKey
        let message: LocalizedStringKey?
    }
}
