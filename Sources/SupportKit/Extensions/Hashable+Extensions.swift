import Foundation

@propertyWrapper
public struct NonHashable<T>: Hashable {
    public var wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public static func == (lhs: NonHashable<T>, rhs: NonHashable<T>) -> Bool { true }
    public func hash(into hasher: inout Hasher) { }
}
