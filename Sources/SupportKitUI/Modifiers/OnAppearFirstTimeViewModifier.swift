import SwiftUI

struct OnAppearFirstTimeViewModifier: ViewModifier {
    let perform: () -> Void
    
    @State private var performed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !performed {
                    perform()
                    performed = true
                }
            }
    }
}

extension View {
    public func onAppearFirstTime(_ perform: @escaping () -> Void) -> some View {
        self.modifier(OnAppearFirstTimeViewModifier(perform: perform))
    }
}
