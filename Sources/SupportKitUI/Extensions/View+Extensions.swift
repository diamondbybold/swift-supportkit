import SwiftUI
import AVKit
import SupportKit

extension View {
    public var shortScreen: Bool {
        let height = UIScreen.main.bounds.size.height
        
        if height < 812.0 {
            return true
        } else {
            return false
        }
    }
    
    @MainActor
    public func hideKeyboard() {
        _ = UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

extension View {
    public func disableTransition(_ disabled: Bool = true) -> some View {
        self.transaction { transaction in
            transaction.disablesAnimations = disabled
        }
    }
}

extension View {
    public func withAnimationAsync(_ duration: Double, _ body: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(.linear(duration: duration)) {
                body()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
    
    public func withoutAnimation(_ body: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            body()
        }
    }
}

extension ViewModifier {
    public func withAnimationAsync(_ duration: Double, _ body: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(.linear(duration: duration)) {
                body()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
    
    public func withoutAnimation(_ body: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            body()
        }
    }
}

extension View {
    @ViewBuilder
    public func screenRelativeFrame(_ axes: Axis.Set,
                                    count: Int,
                                    span: Int,
                                    spacing: CGFloat,
                                    inset: CGFloat) -> some View {
        if axes == .vertical {
            let availableHeight = (UIScreen.main.bounds.height - (inset * 2.0) - (spacing * CGFloat(count - 1)))
            let rowHeight = (availableHeight / CGFloat(count))
            let itemHeight = (rowHeight * CGFloat(span)) + (CGFloat(span - 1) * spacing)
            self.frame(height: itemHeight)
        } else {
            let availableWidth = (UIScreen.main.bounds.width - (inset * 2.0) - (spacing * CGFloat(count - 1)))
            let columnWidth = (availableWidth / CGFloat(count))
            let itemWidth = (columnWidth * CGFloat(span)) + (CGFloat(span - 1) * spacing)
            self.frame(width: itemWidth)
        }
    }
}

// MARK: - Side effects
extension View {
    @MainActor
    public func onChange<V: Equatable>(of value: V, equals: V, perform: @escaping () -> Void) -> some View {
        self.onChange(of: value) { v in if v == equals { perform() } }
    }
    
    @MainActor
    public func onChangeAsync<V: Equatable>(of value: V, debounce: Bool = false, task: @escaping () async -> Void) -> some View {
        self.onChange(of: value) { _ in if debounce { TaskLimiter.debounce { await task() } } else { Task { await task() } } }
    }
    
    @MainActor
    public func onChangeAsync<V: Equatable>(of value: V, equals: V, task: @escaping () async -> Void) -> some View {
        self.onChange(of: value) { v in if v == equals { Task { await task() } } }
    }
    
    @MainActor
    public func onReceiveNotification(_ name: Notification.Name,
                                      perform action: @escaping (Any?, [AnyHashable: Any]?) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name)) {
            action($0.object, $0.userInfo)
        }
    }
}

// MARK: - Media
extension View {
    public func mediaSession(_ category: AVAudioSession.Category,
                             mode: AVAudioSession.Mode = .default,
                             options: AVAudioSession.CategoryOptions = [],
                             idleTimerDisabled: Bool = true) -> some View {
        self
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = idleTimerDisabled
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(category, mode: mode, options: options)
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch { }
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
                
                do {
                    try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                } catch { }
            }
    }
}

// MARK: - Analytics
extension View {
    public func analyticsContextData(_ data: [String: String]) -> some View {
        self.environment(\.analyticsContextData, data)
    }
    
    public func analyticsScreenEvent(_ name: String, parameters: [String: String] = [:]) -> some View {
        self
            .modifier(LogScreenEventViewModifier())
            .environment(\.analyticsScreenEvent, .init(name: name, parameters: parameters))
    }
    
    public func analyticsScreenEvent(_ view: any View, parameters: [String: String] = [:]) -> some View {
        self.analyticsScreenEvent("\(type(of: view))", parameters: parameters)
    }
    
    public func analyticsActionEvent(_ name: String, parameters: [String: String] = [:]) -> some View {
        self.environment(\.analyticsActionEvent, .init(name: name, parameters: parameters))
    }
    
    public func analyticsPrepareForChange<V: Equatable>(of value: V) -> some View {
        self.modifier(PrepareForChangeViewModifier(value: value))
    }
}

struct LogScreenEventViewModifier: ViewModifier {
    @Environment(\.analyticsContextData) private var analyticsContextData
    @Environment(\.analyticsScreenEvent) private var analyticsScreenEvent
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                sharedAnalyticsObject?.contextData = analyticsContextData
                if let analyticsScreenEvent { logScreenEvent(analyticsScreenEvent) }
            }
    }
}

struct PrepareForChangeViewModifier<V: Equatable>: ViewModifier {
    let value: V
    
    @Environment(\.analyticsContextData) private var analyticsContextData
    @Environment(\.analyticsScreenEvent) private var analyticsScreenEvent
    
    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _ in
                sharedAnalyticsObject?.contextData = analyticsContextData
                sharedAnalyticsObject?.screenEvent = analyticsScreenEvent
            }
    }
}
