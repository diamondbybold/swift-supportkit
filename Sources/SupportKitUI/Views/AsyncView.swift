import SwiftUI

public struct AsyncView<Content: View>: View {
    private let expiration: TimeInterval
    private let refreshable: Bool
    private let task: () async throws -> Bool
    private let content: (AsyncViewPhase) -> Content
    
    @State private var lastPage: Int = 1
    @Binding private var currentPage: Int
    
    @State private var phase: AsyncViewPhase = .initial
    @State private var lastUpdated: Date = .distantPast
    
    private var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    @Environment(\.scenePhase) private var schenePhase
    
    public init(expiration: TimeInterval = 120,
                refreshable: Bool = false,
                currentPage: Binding<Int> = .constant(1),
                task: @escaping () async throws -> Bool,
                @ViewBuilder content: @escaping (AsyncViewPhase) -> Content) {
        self.expiration = expiration
        self.refreshable = refreshable
        self._currentPage = currentPage
        self.task = task
        self.content = content
    }
    
    private func performTask(_ expiration: TimeInterval?) async {
        if case .loading = phase { return }
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
            lastPage = currentPage
        } catch is CancellationError {
            currentPage = lastPage
        } catch {
            phase = .error(error)
            currentPage = 1
        }
    }
    
    public var body: some View {
        Group {
            if refreshable {
                ZStack {
                    content(phase)
                }
                .refreshable {
                    currentPage = 1
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
        .onChange(of: currentPage) { value in
            if case .loaded = phase, value > lastPage {
                Task { await performTask(nil) }
            }
        }
    }
}

public enum AsyncViewPhase {
    case initial
    case loading
    case loaded
    case empty
    case error(Error)
}
