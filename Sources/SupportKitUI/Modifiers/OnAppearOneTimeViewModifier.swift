import SwiftUI

struct OnAppearOneTimeViewModifier: ViewModifier {
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
    public func onAppearOneTime(_ perform: @escaping () -> Void) -> some View {
        self.modifier(OnAppearOneTimeViewModifier(perform: perform))
    }
}
