import Foundation

fileprivate var invalidatableContinuations: [String: Any] = [:]

public protocol Invalidatable { }

extension Invalidatable {
    public static var invalidates: AsyncStream<Void> {
        let key = UUID().uuidString
        let sequence = AsyncStream.makeStream(of: Void.self)
        sequence.continuation.onTermination = { @Sendable _ in
            invalidatableContinuations.removeValue(forKey: key)
        }
        invalidatableContinuations[key] = sequence.continuation
        return sequence.stream
    }
    
    public static func invalidate() {
        invalidatableContinuations
            .values
            .compactMap { $0 as? AsyncStream<Void>.Continuation }
            .forEach { $0.yield() }
    }
}
