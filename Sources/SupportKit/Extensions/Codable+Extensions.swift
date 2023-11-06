import Foundation

@propertyWrapper
public struct NullCodable<T>: Codable where T: Codable {
    public var wrappedValue: T?
    
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try? container.decode(T.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(value)
        case .none:
            try container.encodeNil()
        }
    }
}

@propertyWrapper
public struct ISODateCodable: Codable {
    public var wrappedValue: Date?
    
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try? container.decode(String.self) {
        case .some(let value):
            self.wrappedValue = DateFormatter.isoDate.date(from: value)
        case .none:
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(DateFormatter.isoDate.string(from: value))
        case .none:
            try container.encodeNil()
        }
    }
}

@propertyWrapper
public struct ISOTimeCodable: Codable {
    public var wrappedValue: Date?
    
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try? container.decode(String.self) {
        case .some(let value):
            self.wrappedValue = DateFormatter.isoTime.date(from: value)
        case .none:
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(DateFormatter.isoTime.string(from: value))
        case .none:
            try container.encodeNil()
        }
    }
}

@propertyWrapper
public struct ISOTimeWithSecondsCodable: Codable {
    public var wrappedValue: Date?
    
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try? container.decode(String.self) {
        case .some(let value):
            self.wrappedValue = DateFormatter.isoTimeWithSeconds.date(from: value)
        case .none:
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(DateFormatter.isoTimeWithSeconds.string(from: value))
        case .none:
            try container.encodeNil()
        }
    }
}
