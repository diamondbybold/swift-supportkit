import SwiftUI
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
    public func sideEffect<V: Equatable>(of value: V, task: @escaping () async -> Void) -> some View {
        self.onChange(of: value) { _ in Task { await task() } }
    }
        
    @MainActor
    public func sideEffect<V: Equatable>(of value: V, equals: V, task: @escaping () async -> Void) -> some View {
        self.onChange(of: value) { v in if v == equals { Task { await task() } } }
    }
    
    @MainActor
    public func sideEffect<V: Equatable>(of value: V?, task: @escaping (V) async -> Void) -> some View {
        self.onChange(of: value) { v in if let v { Task { await task(v) } } }
    }
    
    @MainActor
    public func sideEffect(of named: Notification.Name, task: @escaping (Notification) async -> Void) -> some View {
        self.task {
            let notifications = NotificationCenter.default.notifications(named: named,
                                                                         object: nil)
            for await notification in notifications {
                await task(notification)
            }
        }
    }
}
