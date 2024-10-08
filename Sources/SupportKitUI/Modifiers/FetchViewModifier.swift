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
    public func fetch<S: Equatable>(refetchTrigger: S,
                                    refetchDebounce: Bool = false,
                                    task: @escaping () async -> Void) -> some View {
        self.modifier(FetchViewModifier(task: task))
            .onChangeAsync(of: refetchTrigger, debounce: refetchDebounce, task: task)
    }
    
    @MainActor
    public func fetch(_ object: any FetchableObject,
                      expiresIn interval: TimeInterval = 900) -> some View {
        self.fetch([object], expiresIn: interval)
    }
    
    @MainActor
    public func fetch<S: Equatable>(_ object: any FetchableObject,
                                    refetchTrigger: S,
                                    refetchDebounce: Bool = false,
                                    expiresIn interval: TimeInterval = 900) -> some View {
        self.fetch([object], refetchTrigger: refetchTrigger, refetchDebounce: refetchDebounce, expiresIn: interval)
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
    public func fetch<S: Equatable>(_ objects: [any FetchableObject],
                                    refetchTrigger: S,
                                    refetchDebounce: Bool = false,
                                    expiresIn interval: TimeInterval = 900) -> some View {
        self.fetch {
            for object in objects {
                if object.needsUpdate(in: interval) {
                    await object.fetch(refreshing: nil)
                }
            }
        }
        .onChangeAsync(of: refetchTrigger, debounce: refetchDebounce) {
            for object in objects {
                await object.fetch(refreshing: false)
            }
        }
    }
}

extension View {
    @MainActor
    public func fetch<T>(_ resource: ResourceRequest<T>,
                         expiresIn interval: TimeInterval = 900,
                         task: @escaping () async throws -> T?) -> some View {
        self.fetch {
            if resource.needsUpdate(in: interval) {
                await resource.fetch(refreshing: nil, task)
            }
        }
    }
    
    @MainActor
    public func fetch<S: Equatable, T>(_ resource: ResourceRequest<T>,
                                       refetchTrigger: S,
                                       refetchDebounce: Bool = false,
                                       expiresIn interval: TimeInterval = 900,
                                       task: @escaping () async throws -> T?) -> some View {
        self.fetch {
            if resource.needsUpdate(in: interval) {
                await resource.fetch(refreshing: nil, task)
            }
        }
        .onChangeAsync(of: refetchTrigger, debounce: refetchDebounce) {
            await resource.fetch(refreshing: false, task)
        }
    }
    
    @MainActor
    public func fetch<T>(_ collection: CollectionRequest<T>,
                         expiresIn interval: TimeInterval = 900,
                         task: @escaping () async throws -> [T]) -> some View {
        self.fetch {
            if collection.needsUpdate(in: interval) {
                await collection.fetch(refreshing: nil, task)
            }
        }
    }
    
    @MainActor
    public func fetch<S: Equatable, T>(_ collection: CollectionRequest<T>,
                                       refetchTrigger: S,
                                       refetchDebounce: Bool = false,
                                       expiresIn interval: TimeInterval = 900,
                                       task: @escaping () async throws -> [T]) -> some View {
        self.fetch {
            if collection.needsUpdate(in: interval) {
                await collection.fetch(refreshing: nil, task)
            }
        }
        .onChangeAsync(of: refetchTrigger, debounce: refetchDebounce) {
            await collection.fetch(refreshing: false, task)
        }
    }
    
    @MainActor
    public func fetch<T>(_ collection: CollectionRequest<T>,
                         expiresIn interval: TimeInterval = 900,
                         task: @escaping (Int) async throws -> ([T], Int)) -> some View {
        self.fetch {
            if collection.needsUpdate(in: interval) {
                await collection.fetch(refreshing: nil, task)
            }
        }
    }
    
    @MainActor
    public func fetch<S: Equatable, T>(_ collection: CollectionRequest<T>,
                                       refetchTrigger: S,
                                       refetchDebounce: Bool = false,
                                       expiresIn interval: TimeInterval = 900,
                                       task: @escaping (Int) async throws -> ([T], Int)) -> some View {
        self.fetch {
            if collection.needsUpdate(in: interval) {
                await collection.fetch(refreshing: nil, task)
            }
        }
        .onChangeAsync(of: refetchTrigger, debounce: refetchDebounce) {
            await collection.fetch(refreshing: false, task)
        }
    }
    
    @MainActor
    public func fetchMoreContent<T>(_ collection: CollectionRequest<T>) -> some View {
        self.task {
            await collection.fetchMoreContents()
        }
    }
}

extension View {
    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               debounce: Bool = false,
                                               resource: ResourceRequest<T>,
                                               refreshing: Bool? = nil) -> some View {
        self.onChangeAsync(of: value, debounce: debounce) {
            await resource.fetch(refreshing: refreshing)
        }
    }
    
    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               equals: V,
                                               resource: ResourceRequest<T>,
                                               refreshing: Bool? = nil) -> some View {
        self.onChangeAsync(of: value, equals: equals) {
            await resource.fetch(refreshing: refreshing)
        }
    }
    
    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               debounce: Bool = false,
                                               collection: CollectionRequest<T>,
                                               refreshing: Bool? = nil) -> some View {
        self.onChangeAsync(of: value, debounce: debounce) {
            await collection.fetch(refreshing: refreshing)
        }
    }
    
    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               equals: V,
                                               collection: CollectionRequest<T>,
                                               refreshing: Bool? = nil) -> some View {
        self.onChangeAsync(of: value, equals: equals) {
            await collection.fetch(refreshing: refreshing)
        }
    }

    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               debounce: Bool = false,
                                               resource: ResourceRequest<T>,
                                               refreshing: Bool? = nil,
                                               task: @escaping () async throws -> T?) -> some View {
        self.onChangeAsync(of: value, debounce: debounce) {
            await resource.fetch(refreshing: refreshing, task)
        }
    }
    
    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               equals: V,
                                               resource: ResourceRequest<T>,
                                               refreshing: Bool? = nil,
                                               task: @escaping () async throws -> T?) -> some View {
        self.onChangeAsync(of: value, equals: equals) {
            await resource.fetch(refreshing: refreshing, task)
        }
    }
    
    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               debounce: Bool = false,
                                               collection: CollectionRequest<T>,
                                               refreshing: Bool? = nil,
                                               task: @escaping () async throws -> [T]) -> some View {
        self.onChangeAsync(of: value, debounce: debounce) {
            await collection.fetch(refreshing: refreshing, task)
        }
    }
    
    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               equals: V,
                                               collection: CollectionRequest<T>,
                                               refreshing: Bool? = nil,
                                               task: @escaping () async throws -> [T]) -> some View {
        self.onChangeAsync(of: value, equals: equals) {
            await collection.fetch(refreshing: refreshing, task)
        }
    }
    
    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               debounce: Bool = false,
                                               collection: CollectionRequest<T>,
                                               refreshing: Bool? = nil,
                                               task: @escaping (Int) async throws -> ([T], Int)) -> some View {
        self.onChangeAsync(of: value, debounce: debounce) {
            await collection.fetch(refreshing: refreshing, task)
        }
    }
    
    @MainActor
    public func fetchOnChange<V: Equatable, T>(of value: V,
                                               equals: V,
                                               collection: CollectionRequest<T>,
                                               refreshing: Bool? = nil,
                                               task: @escaping (Int) async throws -> ([T], Int)) -> some View {
        self.onChangeAsync(of: value, equals: equals) {
            await collection.fetch(refreshing: refreshing, task)
        }
    }
}

// MARK: - Refreshing
extension View {
    @MainActor
    public func refreshableFix(_ task: @escaping () async -> Void) -> some View {
        self.refreshable {
            await Task {
                await task()
            }.value
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
