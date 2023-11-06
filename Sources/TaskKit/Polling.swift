import Foundation

public struct Polling: AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = Result
    
    private let task: () async -> Element?
    private var sleep: TimeInterval? = 0.0
    
    public init(_ task: @escaping () async -> Element?) { self.task = task }
    
    public func makeAsyncIterator() -> Polling { self }
    
    public mutating func next() async -> Element? {
        guard !Task.isCancelled else { return nil }
        guard let sleep else { return nil }
        
        try? await Task.sleep(for: .seconds(sleep))
        
        let result = await task()
        
        switch result {
        case let .notReady(sleep):
            self.sleep = sleep
        case let .ready(_, sleep):
            self.sleep = sleep
        default:
            self.sleep = nil
        }
        
        return result
    }
}

// MARK: - Support Types
extension Polling {
    public enum Result {
        case notReady(sleep: TimeInterval)
        case ready(Any? = nil, sleep: TimeInterval)
        case readyAndDone(Any? = nil)
        
        public func getData<T>() -> T? {
            if case let .ready(data, _) = self { return data as? T }
            else if case let .readyAndDone(data) = self { return data as? T }
            return nil
        }
    }
}
