import SwiftUI

public struct AsyncView<Content: View>: View {
    private let expiration: TimeInterval
    private let refreshable: Bool
    private let task: () async throws -> Bool
    private let content: (AsyncViewPhase) -> Content
    
    @State private var phase: AsyncViewPhase = .loading
    @State private var lastUpdated: Date = .distantPast
    
    private var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    @Environment(\.scenePhase) private var schenePhase
    
    public init(expiration: TimeInterval = 120,
                refreshable: Bool = false,
                task: @escaping () async throws -> Bool,
                @ViewBuilder content: @escaping (AsyncViewPhase) -> Content) {
        self.expiration = expiration
        self.refreshable = refreshable
        self.task = task
        self.content = content
    }
    
    private func performTask(_ expiration: TimeInterval?) async {
        if !(schenePhase == .active || isPreview) { return }
        if let expiration, !lastUpdated.hasExpired(in: expiration) { return }
        
        do {
            if case .loaded = phase { phase = .loaded }
            else { phase = .loading }
            
            if try await task() {
                phase = .loaded
            } else {
                phase = .empty
            }
            
            lastUpdated = .now
        } catch is CancellationError {
        } catch {
            phase = .error(error)
        }
    }
    
    public var body: some View {
        Group {
            if refreshable {
                ZStack {
                    content(phase)
                }
                .refreshable {
                    await performTask(nil)
                }
            } else {
                ZStack {
                    content(phase)
                }
            }
        }
        .task(id: schenePhase) {
            await performTask(expiration)
        }
    }
}

public enum AsyncViewPhase {
    case loading
    case loaded
    case empty
    case error(Error)
}
