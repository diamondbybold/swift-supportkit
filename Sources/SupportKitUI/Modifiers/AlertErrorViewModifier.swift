import SwiftUI

struct AlertErrorViewModifier: ViewModifier {
    @Binding var error: Error?
    
    var localizedError: LocalizedError? { error as? LocalizedError }
    
    func body(content: Content) -> some View {
        content.alert(localizedError?.failureReason ?? "", isPresented: .present(value: $error)) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(localizedError?.recoverySuggestion ?? error?.localizedDescription ?? "")
        }
    }
}

extension View {
    public func alertError(_ error: Binding<Error?>) -> some View {
        self.modifier(AlertErrorViewModifier(error: error))
    }
}
