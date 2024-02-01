import SwiftUI

struct OnAsyncSubmitViewModifier: ViewModifier {
    let triggers: SubmitTriggers
    let action: () async throws -> Void
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    private func performTask() async {
        do {
            try await action()
        } catch let e as LocalizedError {
            navigationContext.alert(title: LocalizedStringKey(e.failureReason ?? ""),
                                    message: LocalizedStringKey(e.recoverySuggestion ?? ""),
                                    confirmation: false) {
                Button("OK") { }
            }
        } catch { }
    }
    
    func body(content: Content) -> some View {
        content
            .onSubmit(of: triggers) {
                Task {
                    await performTask()
                }
            }
    }
}

extension View {
    @MainActor
    public func onAsyncSubmit(of triggers: SubmitTriggers = .text, _ action: @escaping () async throws -> Void) -> some View {
        self.modifier(OnAsyncSubmitViewModifier(triggers: triggers, action: action))
    }
}
