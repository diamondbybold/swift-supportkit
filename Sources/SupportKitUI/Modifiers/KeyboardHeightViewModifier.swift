import SwiftUI

struct KeyboardHeightViewModifier: ViewModifier {
    @Binding var height: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) {
                height = ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)) { _ in
                height = nil
            }
    }
}

extension View {
    public func keyboardHeight(_ height: Binding<CGFloat?>) -> some View {
        self.modifier(KeyboardHeightViewModifier(height: height))
    }
}
