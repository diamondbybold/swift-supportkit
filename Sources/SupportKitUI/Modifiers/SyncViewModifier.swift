import SwiftUI

struct SyncViewModifier: ViewModifier {
    let expiresIn: TimeInterval
    let task: () async -> Void
    
    @Environment(\.scenePhase) private var phase
    @State private var lastSync: Date = .distantPast
    
    private var isRunningForPreviews: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    func body(content: Content) -> some View {
        content
            .task(id: phase) {
                if (phase == .active || isRunningForPreviews),
                   lastSync.hasExpired(in: expiresIn) {
                    await task()
                    lastSync = .now
                }
            }
    }
}

extension View {
    @MainActor
    public func sync(expiresIn interval: TimeInterval = 3600, task: @escaping () async -> Void) -> some View {
        self.modifier(SyncViewModifier(expiresIn: interval, task: task))
    }
    
    @MainActor
    public func sync<S: Equatable>(expiresIn interval: TimeInterval = 3600,
                                   resyncTrigger: S,
                                   resyncDebounce: Bool = false,
                                   task: @escaping () async -> Void) -> some View {
        self.modifier(SyncViewModifier(expiresIn: interval, task: task))
            .onChangeAsync(of: resyncTrigger, debounce: resyncDebounce, task: task)
    }
}
