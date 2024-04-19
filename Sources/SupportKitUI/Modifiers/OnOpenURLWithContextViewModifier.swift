import SwiftUI

struct OnOpenURLWithContextViewModifier: ViewModifier {
    let action: (URL, NavigationContext) -> Void
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                action(url, navigationContext)
            }
    }
}

extension View {
    public func onOpenURLWithContext(perform action: @escaping (URL, NavigationContext) -> Void) -> some View {
        self.modifier(OnOpenURLWithContextViewModifier(action: action))
    }
}
