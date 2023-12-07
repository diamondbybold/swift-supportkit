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
                      CUV: View,
                      EV: View>(_ store: Store,
                                expiration: TimeInterval = 120,
                                perform: @escaping () async throws -> Void,
                                notReadView: () -> NRV,
                                contentUnavailableView: () -> CUV,
                                errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
            } else if store.contentUnavailable {
                contentUnavailableView()
            } else if !store.isReady {
                notReadView()
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
                              CUV: View,
                              EV: View>(_ store: APIStore<T>,
                                        expiration: TimeInterval = 120,
                                        task: @escaping () async throws -> T?,
                                        notReadView: () -> NRV,
                                        contentUnavailableView: () -> CUV,
                                        errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
            } else if store.contentUnavailable {
                contentUnavailableView()
            } else if !store.isReady {
                notReadView()
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
                                CUV: View,
                                EV: View>(_ store: APIStore<T>,
                                          expiration: TimeInterval = 120,
                                          task: @escaping () async throws -> [T],
                                          notReadView: () -> FV,
                                          contentUnavailableView: () -> CUV,
                                          errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
            } else if store.contentUnavailable {
                contentUnavailableView()
            } else if !store.isReady {
                notReadView()
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
                                     CUV: View,
                                     EV: View>(_ store: APIStore<T>,
                                               expiration: TimeInterval = 120,
                                               task: @escaping () async throws -> ([T], Int),
                                               notReadView: () -> NRV,
                                               contentUnavailableView: () -> CUV,
                                               errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
            } else if store.contentUnavailable {
                contentUnavailableView()
            } else if !store.isReady {
                notReadView()
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
