import SwiftUI
import SupportKit

struct FetchViewModifier<T: Fetchable>: ViewModifier {
    @ObservedObject var fetchable: T
    let expiration: TimeInterval
    let refreshable: Bool
    let isActive: Bool
    let task: () async -> Void
    
    @Environment(\.scenePhase) private var phase
    
    private struct FetchTaskId: Equatable {
        let phase: ScenePhase
        let invalidateAt: Date
    }
    
    func body(content: Content) -> some View {
        Group {
            if refreshable {
                content
                    .refreshable {
                        if #available(iOS 17, *) {
                            await task()
                        } else {
                            try? await Task.sleep(for: .seconds(0.5))
                            Task { await task() }
                        }
                    }
            } else {
                content
            }
        }
        .task(id: FetchTaskId(phase: phase, invalidateAt: fetchable.invalidatedAt)) {
            if isActive, (phase == .active || fetchable.isPreview), fetchable.needsUpdate(expiration) {
                await task()
            }
        }
    }
}

extension View {
    @MainActor
    public func fetch<T: Fetchable>(_ fetchable: T,
                                    expiration: TimeInterval = 900,
                                    refreshable: Bool = false,
                                    isActive: Bool = true) -> some View {
        self.fetch(fetchable,
                   expiration: expiration,
                   refreshable: refreshable) {
            await fetchable.fetch()
        }
    }
    
    @MainActor
    public func fetch<T: Fetchable>(_ fetchable: T,
                                    expiration: TimeInterval = 900,
                                    refreshable: Bool = false,
                                    isActive: Bool = true,
                                    task: @escaping () async -> Void) -> some View {
        self.modifier(FetchViewModifier(fetchable: fetchable,
                                        expiration: expiration,
                                        refreshable: refreshable,
                                        isActive: isActive,
                                        task: task))
    }
    
    @MainActor
    public func fetchMoreContent<T: APIModel>(_ collection: APICollection<T>) -> some View {
        self.task {
            await collection.fetchMoreContents()
        }
    }
}
