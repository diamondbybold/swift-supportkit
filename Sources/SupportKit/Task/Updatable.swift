import Foundation

fileprivate var updatableContinuations: [String: Any] = [:]

public protocol Updatable { }

extension Updatable {
    public static var updates: AsyncStream<Self> {
        let key = UUID().uuidString
        let sequence = AsyncStream.makeStream(of: Self.self)
        sequence.continuation.onTermination = { @Sendable _ in
            updatableContinuations.removeValue(forKey: key)
        }
        updatableContinuations[key] = sequence.continuation
        return sequence.stream
    }
    
    public static func update(_ object: Self) {
        updatableContinuations
            .values
            .compactMap { $0 as? AsyncStream<Self>.Continuation }
            .forEach { $0.yield(object) }
    }
}

public protocol Deletable {
    var isDeleted: Bool { get set }
}

extension Array where Element: Identifiable {
    public mutating func update(_ element: Element) {
        if let index = firstIndex(where: { $0.id == element.id }) {
            if let deletableElement = element as? Deletable,
               deletableElement.isDeleted {
                self.remove(at: index)
            } else {
                self[index] = element
            }
        } else {
            self.append(element)
        }
    }
}
