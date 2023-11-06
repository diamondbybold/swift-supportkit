import Foundation

public class TaskLimiter {
    public static let delay = TaskLimiter(.delay, duration: 0.3)
    public static let debounce = TaskLimiter(.debounce)
    public static let throttle = TaskLimiter(.throttle)
    public static let autoDismiss = TaskLimiter(.debounce, duration: 5)
    
    private let policy: Policy
    private let duration: TimeInterval
    private var task: Task<Void, Error>? = nil
    
    public var isActive: Bool { task != nil }
    
    public init(_ policy: Policy,
                duration: TimeInterval = 0.5) {
        self.policy = policy
        self.duration = duration
    }
    
    public func callAsFunction(perform: @escaping () async -> Void) {
        switch policy {
        case .delay:
            delay(perform: perform)
        case .debounce:
            debounce(perform: perform)
        case .throttle:
            throttle(perform: perform)
        }
    }
    
    private func throttle(perform: @escaping () async -> Void) {
        guard !isActive else { return }
        
        task = Task {
            try await Task.sleep(for: .seconds(duration))
            task = nil
        }
        
        Task { await perform() }
    }
    
    private func debounce(perform: @escaping () async -> Void) {
        cancel()
        
        task = Task {
            do {
                try await Task.sleep(for: .seconds(duration))
                await perform()
                task = nil
            } catch { }
        }
    }
    
    private func delay(perform: @escaping () async -> Void) {
        Task {
            do {
                try await Task.sleep(for: .seconds(duration))
                await perform()
            } catch { }
        }
    }
    
    public func cancel() {
        task?.cancel()
    }
}

// MARK: - Support Types
extension TaskLimiter {
    public enum Policy {
        case delay
        case debounce
        case throttle
    }
}
