import Foundation

@MainActor
open class Context: ObservableObject {
    @Published public var ready: Bool = false
    @Published public var error: Error? = nil
    
    deinit { untracking() }
    
    public init() { }
}
