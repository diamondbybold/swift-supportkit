import SwiftUI

struct OnScenePhaseViewModifier: ViewModifier {
    let perform: (ScenePhase) -> Void
    
    @Environment(\.scenePhase) private var scenePhase
    
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { value in
                perform(value)
            }
    }
}

struct OnScenePhaseOfViewModifier: ViewModifier {
    let phase: ScenePhase
    let perform: () -> Void
    
    @Environment(\.scenePhase) private var scenePhase
    
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { value in
                if value == phase {
                    perform()
                }
            }
    }
}

extension View {
    @MainActor
    public func onScenePhase(perform: @escaping (ScenePhase) -> Void) -> some View {
        self.modifier(OnScenePhaseViewModifier(perform: perform))
    }
    
    @MainActor
    public func onScenePhase(of phase: ScenePhase, perform: @escaping () -> Void) -> some View {
        self.modifier(OnScenePhaseOfViewModifier(phase: phase, perform: perform))
    }
}
