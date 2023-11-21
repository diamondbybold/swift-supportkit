import SwiftUI

@MainActor
public class NavigationContext: ObservableObject {
    @Published var path: [DestinationData] = []
    @Published var sheet: DestinationData? = nil
    @Published var fullScreenCover: DestinationData? = nil
    
    @Published var confirmation: Alert? = nil
    @Published var alert: Alert? = nil
    
    var onDismiss: () -> Void = { }
    
    public func destination(_ destination: Destination,
                            disableTransition: Bool = false,
                            @ViewBuilder content: @escaping () -> any View) {
        var transaction = Transaction()
        transaction.disablesAnimations = disableTransition
        withTransaction(transaction) {
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
    }
    
    public func alert(title: LocalizedStringKey,
                      message: LocalizedStringKey? = nil,
                      confirmation: Bool,
                      @ViewBuilder actions: @escaping () -> any View) {
        if confirmation {
            self.confirmation = .init(title: title,
                                      message: message,
                                      actions: actions)
        } else {
            self.alert = .init(title: title,
                               message: message,
                               actions: actions)
        }
    }
    
    public func dismiss() { onDismiss() }
}

// MARK: - Stack Management
extension NavigationContext {
    public var destinationCountInStack: Int { path.count }
    
    public func removeAllDestinationsInStack(disableTransition: Bool = false) {
        var transaction = Transaction()
        transaction.disablesAnimations = disableTransition
        withTransaction(transaction) {
            path.removeAll()
        }
    }
    
    public func removeLastDestinationInStack(_ k: Int = 1, disableTransition: Bool = false) {
        var transaction = Transaction()
        transaction.disablesAnimations = disableTransition
        withTransaction(transaction) {
            path.removeLast(k)
        }
    }
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
    
    struct Alert {
        let title: LocalizedStringKey
        let message: LocalizedStringKey?
        let actions: () -> any View
    }
}
