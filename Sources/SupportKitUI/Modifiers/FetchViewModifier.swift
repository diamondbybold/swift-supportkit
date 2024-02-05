import SwiftUI
import SupportKit

struct FetchViewModifier: ViewModifier {
    let task: () async -> Void
    
    @Environment(\.scenePhase) private var phase
    
    private var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    func body(content: Content) -> some View {
        content
            .task(id: phase) {
                if phase == .active || isPreview {
                    await task()
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
    public func fetchMoreContent<T: APIModel>(_ store: APIStore<T>) -> some View {
        self.task {
            await store.fetchMoreContents()
        }
    }
    
    @MainActor
    public func fetchWithDependency(of object: any FetchableObject, task: @escaping () async -> Void) -> some View {
        self.fetchWithDependency(of: object.lastUpdated, task: task)
    }
    
    @MainActor
    public func fetchWithDependency<V: Equatable>(of value: V, task: @escaping () async -> Void) -> some View {
        self.onChange(of: value) { _ in Task { await task() } }
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
