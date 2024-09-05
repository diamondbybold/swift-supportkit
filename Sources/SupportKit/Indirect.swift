import Foundation

@propertyWrapper
public enum Indirect<T> {
    indirect case wrapped(T)
    
    public init(wrappedValue initialValue: T) {
        self = .wrapped(initialValue)
    }
    
    public var wrappedValue: T {
        get { switch self { case .wrapped(let x): return x } }
        set { self = .wrapped(newValue) }
    }
}

extension Indirect: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        try self.init(wrappedValue: T(from: decoder))
    }
}

extension Indirect: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(_: Indirect<T>.Type, forKey key: Key) throws -> Indirect<T> {
        return try Indirect(wrappedValue: decode(T.self, forKey: key))
    }
    
    public func decode<T: Decodable>(_: Indirect<Optional<T>>.Type, forKey key: Key) throws -> Indirect<Optional<T>> {
        return try Indirect(wrappedValue: decodeIfPresent(T.self, forKey: key))
    }
}
