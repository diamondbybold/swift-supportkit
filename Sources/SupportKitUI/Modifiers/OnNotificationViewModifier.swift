import SwiftUI

struct OnNotificationViewModifier: ViewModifier {
    @Binding var notification: UNNotificationResponse?
    let perform: (UNNotificationResponse, NavigationContext) -> Bool
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    func body(content: Content) -> some View {
        content.onAppear {
            if let n = notification {
                if perform(n, navigationContext) {
                    notification = nil
                }
            }
        }
        .onChange(of: notification) {
            if let n = $0 {
                if perform(n, navigationContext) {
                    notification = nil
                }
            }
        }
    }
}

extension View {
    public func onNotification(_ notification: Binding<UNNotificationResponse?>,
                               perform: @escaping (UNNotificationResponse, NavigationContext) -> Bool) -> some View {
        self.modifier(OnNotificationViewModifier(notification: notification,
                                                 perform: perform))
    }
    
    public func onNotification(_ notification: Binding<UNNotificationResponse?>,
                               perform: @escaping (UNNotificationResponse) -> Bool) -> some View {
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
