import SwiftUI

struct OnNotificationViewModifier: ViewModifier {
    @Binding var notification: UNNotification?
    let destination: NavigationContext.Destination
    let destinationContent: (UNNotification) -> (any View)?
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    private func handleNotification(_ notification: UNNotification) {
        guard navigationContext.isActive else { return }
        if destination != .stack, navigationContext.isModalActive { return }
        guard let content = destinationContent(notification) else { return }
        navigationContext.destination(destination) { content }
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            if let n = notification {
                handleNotification(n)
                notification = nil
            }
        }
        .onChange(of: notification) {
            if let n = $0 {
                handleNotification(n)
                notification = nil
            }
        }
    }
}

extension View {
    public func onNotification(_ notification: Binding<UNNotification?>,
                               destination: NavigationContext.Destination,
                               @ViewBuilder content: @escaping (UNNotification) -> (any View)?) -> some View {
        self.modifier(OnNotificationViewModifier(notification: notification,
                                                 destination: destination,
                                                 destinationContent: content))
        
    }
    
    public func onNotification(_ notification: Binding<UNNotification?>,
                               perform: @escaping (UNNotification) -> Bool) -> some View {
        self.onAppear {
            if let n = notification.wrappedValue {
                if perform(n) {
                    notification.wrappedValue = nil
                }
            }
        }
        .onChange(of: notification.wrappedValue) {
            if let n = $0 {
                if perform(n) {
                    notification.wrappedValue = nil
                }
            }
        }
    }
}
