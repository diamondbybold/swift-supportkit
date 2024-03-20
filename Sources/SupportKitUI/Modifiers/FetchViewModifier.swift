import SwiftUI
import SupportKit

struct FetchViewModifier: ViewModifier {
    let task: () async -> Void
    
    @Environment(\.scenePhase) private var phase
    
    private var isRunningForPreviews: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    func body(content: Content) -> some View {
        content
            .task(id: phase) {
                if phase == .active || isRunningForPreviews {
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
                      expiresIn interval: TimeInterval = 900) -> some View {
        self.fetch([object], expiresIn: interval)
    }
    
    @MainActor
    public func fetch(_ objects: [any FetchableObject],
                      expiresIn interval: TimeInterval = 900) -> some View {
        self.fetch {
            for object in objects {
                if object.needsUpdate(in: interval) {
                    await object.fetch(refreshing: nil)
                }
            }
        }
    }
    
    @MainActor
    public func fetch<T>(_ store: Store<T>,
                         _ fetchRequest: Store<T>.FetchRequest,
                         expiresIn interval: TimeInterval = 900) -> some View {
        self.fetch {
            if store.needsUpdate(in: interval) {
                await store.fetch(fetchRequest, refreshing: nil)
            }
        }
    }
    
    @MainActor
    public func fetch<T>(_ store: Store<T>,
                         _ fetchRequest: @escaping (Int) async throws -> ([T], Int?),
                         expiresIn interval: TimeInterval = 900) -> some View {
        self.fetch {
            if store.needsUpdate(in: interval) {
                await store.fetch(refreshing: nil, fetchRequest)
            }
        }
    }
    
    @MainActor
    public func fetch<T>(_ store: Store<T>,
                         _ fetchRequest: @escaping () async throws -> [T],
                         expiresIn interval: TimeInterval = 900) -> some View {
        self.fetch {
            if store.needsUpdate(in: interval) {
                await store.fetch(refreshing: nil, fetchRequest)
            }
        }
    }
    
    @MainActor
    public func fetch<T>(_ store: Store<T>,
                         _ fetchRequest: @escaping () async throws -> T?,
                         expiresIn interval: TimeInterval = 900) -> some View {
        self.fetch {
            if store.needsUpdate(in: interval) {
                await store.fetch(refreshing: nil, fetchRequest)
            }
        }
    }
    
    @MainActor
    public func fetchMoreContent<T>(_ store: Store<T>) -> some View {
        self.task {
            await store.fetchMoreContents()
        }
    }
    
    @MainActor
    public func fetchMoreContent<T>(_ collection: APIPagedCollection<T>) -> some View {
        self.task {
            await collection.fetchMoreContents()
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
    public func refreshableFix(_ task: @escaping () async -> Void) -> some View {
        self.refreshable {
            if #available(iOS 17, *) {
                await task()
            } else {
                try? await Task.sleep(for: .seconds(0.5))
                Task {
                    await task()
                }
            }
        }
    }
    
    @MainActor
    public func refreshable(_ object: any FetchableObject) -> some View {
        self.refreshable([object])
    }
    
    @MainActor
    public func refreshable(_ objects: [any FetchableObject]) -> some View {
        self.refreshableFix {
            for object in objects {
                await object.fetch(refreshing: true)
            }
        }
    }
}
