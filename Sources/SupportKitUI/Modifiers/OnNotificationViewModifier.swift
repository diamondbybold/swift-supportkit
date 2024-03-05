import SwiftUI

struct OnNotificationViewModifier: ViewModifier {
    @Binding var notificationResponse: UNNotificationResponse?
    let perform: (UNNotificationResponse, NavigationContext) -> Bool
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    func body(content: Content) -> some View {
        content.onAppear {
            if let n = notificationResponse {
                if perform(n, navigationContext) {
                    notificationResponse = nil
                }
            }
        }
        .onChange(of: notificationResponse) {
            if let n = $0 {
                if perform(n, navigationContext) {
                    notificationResponse = nil
                }
            }
        }
    }
}

extension View {
    public func onNotification(_ notificationResponse: Binding<UNNotificationResponse?>,
                               perform: @escaping (UNNotificationResponse, NavigationContext) -> Bool) -> some View {
        self.modifier(OnNotificationViewModifier(notificationResponse: notificationResponse,
                                                 perform: perform))
    }
    
    public func onNotification(_ notificationResponse: Binding<UNNotificationResponse?>,
                               perform: @escaping (UNNotificationResponse) -> Bool) -> some View {
        self.onAppear {
            if let n = notificationResponse.wrappedValue {
                if perform(n) {
                    notificationResponse.wrappedValue = nil
                }
            }
        }
        .onChange(of: notificationResponse.wrappedValue) {
            if let n = $0 {
                if perform(n) {
                    notificationResponse.wrappedValue = nil
                }
            }
        }
    }
}
