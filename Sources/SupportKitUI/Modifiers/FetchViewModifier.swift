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
                store.error = nil
                try await perform()
            } catch {
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetch<NRV: View,
                      EV: View>(_ store: Store,
                                expiration: TimeInterval = 120,
                                perform: @escaping () async throws -> Void,
                                notReadView: () -> NRV,
                                errorView: (Error) -> EV) -> some View {
        self.overlay {
            if !store.isReady {
                notReadView()
            } else if let e = store.error {
                errorView(e)
            }
        }
        .fetch(store, expiration: expiration, perform: perform)
    }
    
    @MainActor
    public func fetchResource<T: APIModel>(_ store: APIStore<T>,
                                           expiration: TimeInterval = 120,
                                           task: @escaping () async throws -> T?) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                store.error = nil
                store.resource = try await task()
            } catch {
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchResource<T: APIModel,
                              NRV: View,
                              EV: View,
                              UV: View>(_ store: APIStore<T>,
                                        expiration: TimeInterval = 120,
                                        task: @escaping () async throws -> T?,
                                        notReadView: () -> NRV,
                                        errorView: (Error) -> EV,
                                        unavailableView: () -> UV) -> some View {
        self.overlay {
            if !store.isReady {
                notReadView()
            } else if let e = store.error {
                errorView(e)
            } else if store.contentUnavailable {
                unavailableView()
            }
        }
        .fetchResource(store, expiration: expiration, task: task)
    }
    
    @MainActor
    public func fetchCollection<T: APIModel>(_ store: APIStore<T>,
                                             expiration: TimeInterval = 120,
                                             task: @escaping () async throws -> [T]) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                store.error = nil
                store.collection = try await task()
            } catch {
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchCollection<T: APIModel,
                                FV: View,
                                EV: View,
                                UV: View>(_ store: APIStore<T>,
                                          expiration: TimeInterval = 120,
                                          task: @escaping () async throws -> [T],
                                          notReadView: () -> FV,
                                          errorView: (Error) -> EV,
                                          unavailableView: () -> UV) -> some View {
        self.overlay {
            if !store.isReady {
                notReadView()
            } else if let e = store.error {
                errorView(e)
            } else if store.contentUnavailable {
                unavailableView()
            }
        }
        .fetchCollection(store, expiration: expiration, task: task)
    }
    
    @MainActor
    public func fetchPagedCollection<T: APIModel>(_ store: APIStore<T>,
                                                  expiration: TimeInterval = 120,
                                                  task: @escaping () async throws -> ([T], Int)) -> some View {
        self.modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
            do {
                store.error = nil
                let (c, t) = try await task()
                store.collection = c
                store.total = t
                store.currentPage = 1
            } catch {
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchPagedCollection<T: APIModel,
                                     NRV: View,
                                     EV: View,
                                     UV: View>(_ store: APIStore<T>,
                                               expiration: TimeInterval = 120,
                                               task: @escaping () async throws -> ([T], Int),
                                               notReadView: () -> NRV,
                                               errorView: (Error) -> EV,
                                               unavailableView: () -> UV) -> some View {
        self.overlay {
            if !store.isReady {
                notReadView()
            } else if let e = store.error {
                errorView(e)
            } else if store.contentUnavailable {
                unavailableView()
            }
        }
        .fetchPagedCollection(store, expiration: expiration, task: task)
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
