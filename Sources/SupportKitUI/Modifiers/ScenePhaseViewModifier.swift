import SwiftUI

struct ScenePhaseViewModifier: ViewModifier {
    let phase: ScenePhase
    let task: () async -> Void
    
    @Environment(\.scenePhase) private var scenePhase
    
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { value in
                if value == phase {
                    Task { await task() }
                }
            }
    }
}

extension View {
    @MainActor
    public func sideEffect(of phase: ScenePhase, task: @escaping () async -> Void) -> some View {
        self.modifier(ScenePhaseViewModifier(phase: phase, task: task))
    }
}
