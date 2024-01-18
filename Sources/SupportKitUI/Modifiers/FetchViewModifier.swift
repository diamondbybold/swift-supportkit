import SwiftUI
import SupportKit

struct FetchViewModifier: ViewModifier {
    @ObservedObject var store: Store
    let expiration: TimeInterval
    let refreshable: Bool
    let perform: () async -> Void
    
    @Environment(\.scenePhase) private var phase
    
    struct FetchTaskId: Equatable {
        let phase: ScenePhase
        let lastInvalidate: Date
    }
    
    var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    func body(content: Content) -> some View {
        if refreshable {
            content
                .refreshable {
                    await perform()
                }
                .task(id: FetchTaskId(phase: phase, lastInvalidate: store.invalidatedAt)) {
                    if (phase == .active || isPreview),
                       store.needsUpdate(expiration) {
                        await perform()
                    }
                }
        } else {
            content
                .task(id: FetchTaskId(phase: phase, lastInvalidate: store.invalidatedAt)) {
                    if (phase == .active || isPreview),
                       store.needsUpdate(expiration) {
                        await perform()
                    }
                }
        }
    }
}

struct FetchableViewModifier<T: Fetchable>: ViewModifier {
    let fetchable: T
    let includes: [T]
    let expiration: TimeInterval
    let refreshable: Bool
    @Binding var refetch: Bool
    let prepareForFetch: () -> Void
    
    @Environment(\.scenePhase) private var phase
    
    var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    struct FetchTaskId: Equatable {
        let phase: ScenePhase
        let lastInvalidate: Date
    }
    
    private func performFetch() async {
        prepareForFetch()
        await fetchable.fetch()
        
        if !includes.isEmpty {
            prepareForFetch()
            for f in includes { await f.fetch() }
        }
    }
    
    private func performRefetch() async {
        prepareForFetch()
        await fetchable.refetch()
        
        if !includes.isEmpty {
            prepareForFetch()
            for f in includes { await f.refetch() }
        }
    }
    
    func body(content: Content) -> some View {
        Group {
            if refreshable {
                content
                    .refreshable {
                        await performFetch()
                    }
            } else {
                content
            }
        }
        .task(id: FetchTaskId(phase: phase, lastInvalidate: fetchable.invalidatedAt)) {
            if (phase == .active || isPreview),
               fetchable.needsUpdate(expiration) {
                await performFetch()
            }
        }
        .onChange(of: refetch) { value in
            if value {
                refetch = false
                Task { performRefetch }
            }
        }
    }
}

extension View {
    public func fetch<T: Fetchable>(_ fetchable: T,
                                    includes: [T] = [],
                                    expiration: TimeInterval = 120,
                                    refreshable: Bool = false,
                                    refetch: Binding<Bool> = .constant(false),
                                    prepareForFetch: @escaping () -> Void = { }) -> some View {
        self.modifier(FetchableViewModifier(fetchable: fetchable,
                                            includes: includes,
                                            expiration: expiration,
                                            refreshable: refreshable,
                                            refetch: refetch,
                                            prepareForFetch: prepareForFetch))
    }
}

extension View {
    @MainActor
    public func fetch(_ store: Store,
                      expiration: TimeInterval = 120,
                      refreshable: Bool = false,
                      perform: @escaping () async throws -> Void) -> some View {
        self.modifier(FetchViewModifier(store: store,
                                        expiration: expiration,
                                        refreshable: refreshable,
                                        perform: {
            do {
                try await perform()
                store.fetchedAt = .now
            } catch {
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetch<SS: ShapeStyle,
                      NRV: View,
                      CUV: View,
                      EV: View>(_ store: Store,
                                backgroundStyle: SS = .clear,
                                expiration: TimeInterval = 120,
                                refreshable: Bool = false,
                                perform: @escaping () async throws -> Void,
                                notReadyView: () -> NRV,
                                contentUnavailableView: () -> CUV,
                                errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt > .distantPast, store.contentUnavailable {
                contentUnavailableView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt == .distantPast {
                notReadyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            }
        }
        .fetch(store, expiration: expiration, refreshable: refreshable, perform: perform)
    }
    
    @MainActor
    public func fetchResource<T: APIModel>(_ store: APIStore<T>,
                                           expiration: TimeInterval = 120,
                                           refreshable: Bool = false,
                                           task: @escaping () async throws -> T?) -> some View {
        self.modifier(FetchViewModifier(store: store,
                                        expiration: expiration,
                                        refreshable: refreshable,
                                        perform: {
            do {
                store.error = nil
                store.resource = try await task()
                store.fetchedAt = .now
            } catch {
                store.collection.removeAll()
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchResource<T: APIModel,
                              SS: ShapeStyle,
                              NRV: View,
                              CUV: View,
                              EV: View>(_ store: APIStore<T>,
                                        expiration: TimeInterval = 120,
                                        refreshable: Bool = false,
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
            } else if store.fetchedAt > .distantPast, store.contentUnavailable {
                contentUnavailableView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt == .distantPast {
                notReadyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            }
        }
        .fetchResource(store, expiration: expiration, refreshable: refreshable, task: task)
    }
    
    @MainActor
    public func fetchCollection<T: APIModel>(_ store: APIStore<T>,
                                             expiration: TimeInterval = 120,
                                             refreshable: Bool = false,
                                             task: @escaping () async throws -> [T]) -> some View {
        self.modifier(FetchViewModifier(store: store,
                                        expiration: expiration,
                                        refreshable: refreshable,
                                        perform: {
            do {
                store.error = nil
                store.collection = try await task()
                store.fetchedAt = .now
            } catch {
                store.collection.removeAll()
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchCollection<T: APIModel,
                                SS: ShapeStyle,
                                FV: View,
                                CUV: View,
                                EV: View>(_ store: APIStore<T>,
                                          expiration: TimeInterval = 120,
                                          refreshable: Bool = false,
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
            } else if store.fetchedAt > .distantPast, store.contentUnavailable {
                contentUnavailableView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt == .distantPast {
                notReadyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            }
        }
        .fetchCollection(store, expiration: expiration, refreshable: refreshable, task: task)
    }
    
    @MainActor
    public func fetchPagedCollection<T: APIModel>(_ store: APIStore<T>,
                                                  expiration: TimeInterval = 120,
                                                  refreshable: Bool = false,
                                                  task: @escaping () async throws -> APIResults<T>) -> some View {
        self.modifier(FetchViewModifier(store: store,
                                        expiration: expiration,
                                        refreshable: refreshable,
                                        perform: {
            do {
                store.error = nil
                let c = try await task()
                store.setPagedCollection(c)
                store.fetchedAt = .now
            } catch {
                store.collection.removeAll()
                store.error = error
            }
        }))
    }
    
    @MainActor
    public func fetchPagedCollection<T: APIModel,
                                     SS: ShapeStyle,
                                     NRV: View,
                                     CUV: View,
                                     EV: View>(_ store: APIStore<T>,
                                               expiration: TimeInterval = 120,
                                               refreshable: Bool = false,
                                               backgroundStyle: SS = .clear,
                                               task: @escaping () async throws -> APIResults<T>,
                                               notReadyView: () -> NRV,
                                               contentUnavailableView: () -> CUV,
                                               errorView: (Error) -> EV) -> some View {
        self.overlay {
            if let e = store.error {
                errorView(e)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt > .distantPast, store.contentUnavailable {
                contentUnavailableView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            } else if store.fetchedAt == .distantPast {
                notReadyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundStyle)
            }
        }
        .fetchPagedCollection(store, expiration: expiration, refreshable: refreshable, task: task)
    }
    
    @MainActor
    public func fetchMoreContent<T: APIModel>(_ store: APIStore<T>,
                                              task: @escaping () async throws -> APIResults<T>) -> some View {
        self.task {
            do {
                store.moreContentError = nil
                let c = try await task()
                store.appendMoreContentToPagedCollection(c)
                store.fetchedAt = .now
            } catch {
                store.moreContentError = error
            }
        }
    }
    
    @MainActor
    public func fetchMoreContent<T: APIModel>(_ store: APIStore<T>,
                                              task: @escaping () async throws -> [T]) -> some View {
        self.task {
            do {
                store.moreContentError = nil
                let c = try await task()
                store.appendMoreContentToPagedCollection(c)
                store.fetchedAt = .now
            } catch {
                store.moreContentError = error
            }
        }
    }
}
