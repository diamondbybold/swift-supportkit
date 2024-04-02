import SwiftUI

struct OnSaveViewModifier: ViewModifier {
    let condition: Bool
    let task: () async throws -> Void
    
    @Environment(\.scenePhase) private var phase
    @EnvironmentObject private var navigationContext: NavigationContext
    
    private func performTask() async {
        do {
            try await task()
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
            .onDisappear {
                if condition {
                    Task { await performTask() }
                }
            }
            .onChange(of: phase) { value in
                if condition, value == .inactive {
                    Task { await performTask() }
                }
            }
    }
}

extension View {
    @MainActor
    public func onSave(_ condition: Bool = true, task: @escaping () async throws -> Void) -> some View {
        self.modifier(OnSaveViewModifier(condition: condition, task: task))
    }
}
