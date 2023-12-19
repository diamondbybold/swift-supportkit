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
            .task(id: FetchTaskId(phase: phase, lastInvalidate: store.invalidatedAt)) {
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
        self
            .animation(.default, value: store.updatedAt)
            .modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
                do {
                    try await perform()
                } catch {
                    store.error = error
                }
                store.updateTimestamps()
        }))
    }
    
    @MainActor
    public func fetch<SS: ShapeStyle,
                      NRV: View,
                      CUV: View,
                      EV: View>(_ store: Store,
                                backgroundStyle: SS = .clear,
                                expiration: TimeInterval = 120,
                                perform: @escaping () async throws -> Void,
                                notReadyView: () -> NRV,
                                contentUnavailableView: () -> CUV,
                                errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.contentUnavailable {
                contentUnavailableView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt == .distantPast {
                notReadyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            }
        }
        .fetch(store, expiration: expiration, perform: perform)
    }
    
    @MainActor
    public func fetchResource<T: APIModel>(_ store: APIStore<T>,
                                           expiration: TimeInterval = 120,
                                           task: @escaping () async throws -> T?) -> some View {
        self
            .animation(.default, value: store.updatedAt)
            .modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
                do {
                    store.resource = try await task()
                } catch {
                    store.error = error
                }
                store.updateTimestamps()
        }))
    }
    
    @MainActor
    public func fetchResource<T: APIModel,
                              SS: ShapeStyle,
                              NRV: View,
                              CUV: View,
                              EV: View>(_ store: APIStore<T>,
                                        expiration: TimeInterval = 120,
                                        backgroundStyle: SS = .clear,
                                        task: @escaping () async throws -> T?,
                                        notReadyView: () -> NRV,
                                        contentUnavailableView: () -> CUV,
                                        errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.contentUnavailable {
                contentUnavailableView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt == .distantPast {
                notReadyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            }
        }
        .fetchResource(store, expiration: expiration, task: task)
    }
    
    @MainActor
    public func fetchCollection<T: APIModel>(_ store: APIStore<T>,
                                             expiration: TimeInterval = 120,
                                             task: @escaping () async throws -> [T]) -> some View {
        self
            .animation(.default, value: store.updatedAt)
            .modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
                do {
                    store.collection = try await task()
                } catch {
                    store.error = error
                }
                store.updateTimestamps()
        }))
    }
    
    @MainActor
    public func fetchCollection<T: APIModel,
                                SS: ShapeStyle,
                                FV: View,
                                CUV: View,
                                EV: View>(_ store: APIStore<T>,
                                          expiration: TimeInterval = 120,
                                          backgroundStyle: SS = .clear,
                                          task: @escaping () async throws -> [T],
                                          notReadyView: () -> FV,
                                          contentUnavailableView: () -> CUV,
                                          errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.contentUnavailable {
                contentUnavailableView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt == .distantPast {
                notReadyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            }
        }
        .fetchCollection(store, expiration: expiration, task: task)
    }
    
    @MainActor
    public func fetchPagedCollection<T: APIModel>(_ store: APIStore<T>,
                                                  expiration: TimeInterval = 120,
                                                  task: @escaping () async throws -> ([T], Int)) -> some View {
        self
            .animation(.default, value: store.updatedAt)
            .modifier(FetchViewModifier(store: store, expiration: expiration, perform: {
                do {
                    let (c, t) = try await task()
                    store.setPagedCollection((c, t))
                } catch {
                    store.error = error
                }
                store.updateTimestamps()
        }))
    }
    
    @MainActor
    public func fetchPagedCollection<T: APIModel,
                                     SS: ShapeStyle,
                                     NRV: View,
                                     CUV: View,
                                     EV: View>(_ store: APIStore<T>,
                                               expiration: TimeInterval = 120,
                                               backgroundStyle: SS = .clear,
                                               task: @escaping () async throws -> ([T], Int),
                                               notReadyView: () -> NRV,
                                               contentUnavailableView: () -> CUV,
                                               errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.contentUnavailable {
                contentUnavailableView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt == .distantPast {
                notReadyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
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
                store.appendMoreContentToPagedCollection(c)
            } catch {
                store.moreContentError = error
            }
            store.updatedAt = .now
        }
    }
}
