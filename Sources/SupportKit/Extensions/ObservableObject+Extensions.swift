import Foundation
import Combine

extension ObservableObject {
    @MainActor
    public func sendObjectWillChange() { (objectWillChange as? ObservableObjectPublisher)?.send() }
}

extension ObservableObject {
    public func tracking(_ task: @escaping () async -> Void) {
        TaskRegistrar.shared(object: self, task: task)
    }
    
    public func untracking() {
        TaskRegistrar.shared.cancelWithObject(self)
    }
}
