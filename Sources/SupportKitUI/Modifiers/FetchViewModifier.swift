import SwiftUI
import SupportKit

struct FetchViewModifier: ViewModifier {
    var expiresIn: TimeInterval? = nil
    let task: () async -> Void
    
    @Environment(\.scenePhase) private var phase
    @State private var lastUpdated: Date = .distantPast
    
    private var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    func body(content: Content) -> some View {
        content
            .task(id: phase) {
                if phase == .active || isPreview {
                    if let expiresIn {
                        if lastUpdated.hasExpired(in: expiresIn) {
                            await task()
                        }
                    } else {
                        await task()
                    }
                }
            }
    }
}

extension View {
    @MainActor
    public func fetch(_ task: @escaping () async -> Void) -> some View {
        self.modifier(FetchViewModifier(task: task))
    }
    
    @MainActor
    public func fetch(expiresIn: TimeInterval, _ task: @escaping () async -> Void) -> some View {
        self.modifier(FetchViewModifier(expiresIn: expiresIn, task: task))
    }
    
    @MainActor
    public func fetch(_ object: any FetchableObject,
                      option: FetchOption? = .expiresIn15min) -> some View {
        self.fetch([object], option: option)
    }
    
    @MainActor
    public func fetch(_ objects: [any FetchableObject],
                      option: FetchOption? = .expiresIn15min) -> some View {
        self.fetch {
            for object in objects {
                await object.fetch(option: option)
            }
        }
    }
    
    @MainActor
    public func fetchMoreContent<T: APIModel>(_ store: APIPagedCollection<T>) -> some View {
        self.task {
            await store.fetchMoreContents()
        }
    }
}
    
// MARK: - Side effects
extension View {
    @MainActor
    public func sideEffect(of object: any FetchableObject, task: @escaping () async -> Void) -> some View {
        self.sideEffect(of: object.lastUpdated, task: task)
    }
}

// MARK: - Refreshing
extension View {
    @MainActor
    public func refreshable(_ object: any FetchableObject) -> some View {
        self.refreshable([object])
    }
    
    @MainActor
    public func refreshable(_ objects: [any FetchableObject]) -> some View {
        self.refreshable {
            if #available(iOS 17, *) {
                for object in objects {
                    await object.fetch(option: .refresh)
                }
            } else {
                try? await Task.sleep(for: .seconds(0.5))
                Task {
                    for object in objects {
                        await object.fetch(option: .refresh)
                    }
                }
            }
        }
    }
}
