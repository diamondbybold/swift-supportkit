import SwiftUI
import SupportKit

struct FetchViewModifier: ViewModifier {
    @ObservedObject var store: Store
    let expiration: TimeInterval
    let perform: () async -> Void
    
    @Environment(\.scenePhase) private var phase
    
    struct FetchTaskId: Equatable {
        let phase: ScenePhase
        let isInvalidated: Bool
    }
    
    func body(content: Content) -> some View {
        content
            .task(id: FetchTaskId(phase: phase, isInvalidated: store.state.isInvalidated)) {
                if phase == .active,
                   store.state.needsUpdate(expiration) {
                    await perform()
                }
            }
    }
}

extension View {
    @MainActor
    public func fetch(_ store: Store,
                      expiration: TimeInterval = 120,
                      perform: @escaping () async -> Void) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: perform))
    }
    
    @MainActor
    public func fetchResource<T: APIModel>(_ store: APIStore<T>,
                                           expiration: TimeInterval = 120,
                                           task: @escaping () async throws -> T?) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                store.resource = try await task()
            } catch {
                store.state = .error(error)
            }
        }))
    }
    
    @MainActor
    public func fetchCollection<T: APIModel>(_ store: APIStore<T>,
                                             expiration: TimeInterval = 120,
                                             task: @escaping () async throws -> [T]) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                store.collection = try await task()
            } catch {
                store.state = .error(error)
            }
        }))
    }
    
    @MainActor
    public func fetchPagedCollection<T: APIModel>(_ store: APIStore<T>,
                                                  expiration: TimeInterval = 120,
                                                  task: @escaping () async throws -> ([T], Int)) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                let (c, t) = try await task()
                store.collection = c
                store.total = t
                store.currentPage = 1
            } catch {
                store.state = .error(error)
            }
        }))
    }
    
    @MainActor
    public func fetchMoreContent<T: APIModel>(_ store: APIStore<T>,
                                              task: @escaping () async throws -> [T]) -> some View {
        self.task {
            do {
                let c = try await task()
                store.collection.append(contentsOf: c)
                store.currentPage += 1
            } catch {
                store.state = .moreContentError(error)
            }
        }
    }
}
