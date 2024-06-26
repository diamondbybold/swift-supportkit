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
    public func onNotification(_ named: Notification.Name, perform: @escaping (Notification) -> Void) -> some View {
        self.task {
            let notifications = NotificationCenter.default.notifications(named: named,
                                                                         object: nil)
            for await notification in notifications {
                perform(notification)
            }
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
    public func analyticsContext(_ context: String) -> some View {
        self.environment(\.analyticsContextIdentifier, context)
            .onAppear {
                sharedAnalyticsObject?.contextIdentifier = context
            }
    }
    
    public func screenEvent(_ identifier: String, parameters: [String: String]? = nil) -> some View {
        self.environment(\.analyticsScreenIdentifier, identifier)
            .onAppear {
                sharedAnalyticsObject?.screenIdentifier = identifier
                logScreenEvent(identifier, parameters: parameters)
            }
    }
    
    public func screenEvent(_ view: any View, parameters: [String: String]? = nil) -> some View {
        self.screenEvent("\(type(of: view))", parameters: parameters)
    }
    
    public func actionEvent(_ name: String, identifier: String, parameters: [String: String]? = nil) -> some View {
        self.environment(\.analyticsActionLog, .init(name: name, identifier: identifier, parameters: parameters))
    }
}
