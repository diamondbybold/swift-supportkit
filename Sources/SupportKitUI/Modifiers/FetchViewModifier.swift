import SwiftUI
import SupportKit

struct FetchViewModifier: ViewModifier {
    @ObservedObject var store: Store
    let expiration: TimeInterval
    let perform: () async -> Void
    
    @Environment(\.scenePhase) private var phase
    
    struct FetchTaskId: Equatable {
        let phase: ScenePhase
        let lastInvalidate: Date
    }
    
    var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    func body(content: Content) -> some View {
        content
            .task(id: FetchTaskId(phase: phase, lastInvalidate: store.lastInvalidate)) {
                if (phase == .active || isPreview),
                   store.needsUpdate(expiration) {
                    await perform()
                }
            }
    }
}

extension View {
    @MainActor
    public func fetch(_ store: Store,
                      expiration: TimeInterval = 120,
                      perform: @escaping () async throws -> Void) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                store.ready = false
                store.error = nil
                try await perform()
                store.ready = true
            } catch {
                store.ready = false
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchResource<T: APIModel>(_ store: APIStore<T>,
                                           expiration: TimeInterval = 120,
                                           task: @escaping () async throws -> T?) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                store.ready = false
                store.error = nil
                store.resource = try await task()
                store.ready = true
            } catch {
                store.ready = false
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchCollection<T: APIModel>(_ store: APIStore<T>,
                                             expiration: TimeInterval = 120,
                                             task: @escaping () async throws -> [T]) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                store.ready = false
                store.error = nil
                store.collection = try await task()
                store.ready = true
            } catch {
                store.ready = false
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchPagedCollection<T: APIModel>(_ store: APIStore<T>,
                                                  expiration: TimeInterval = 120,
                                                  task: @escaping () async throws -> ([T], Int)) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                store.ready = false
                store.error = nil
                let (c, t) = try await task()
                store.collection = c
                store.total = t
                store.currentPage = 1
                store.ready = true
            } catch {
                store.ready = false
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchMoreContent<T: APIModel>(_ store: APIStore<T>,
                                              task: @escaping () async throws -> [T]) -> some View {
        self.task {
            do {
                store.moreContentError = nil
                let c = try await task()
                store.collection.append(contentsOf: c)
                store.currentPage += 1
            } catch {
                store.moreContentError = error
            }
        }
    }
}
