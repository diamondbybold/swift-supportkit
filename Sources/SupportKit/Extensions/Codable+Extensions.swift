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

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(_ type: NullCodable<T>.Type, forKey key: Self.Key) throws -> NullCodable<T> {
        try decodeIfPresent(type, forKey: key) ?? NullCodable<T>(wrappedValue: nil)
    }
}

@propertyWrapper
public struct ISODateTimeUTCCodable: Codable {
    public var wrappedValue: Date?
    
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try? container.decode(String.self) {
        case .some(let value):
            self.wrappedValue = DateFormatter.isoDateTimeUTC.date(from: value)
        case .none:
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(DateFormatter.isoDateTimeUTC.string(from: value))
        case .none:
            try container.encodeNil()
        }
    }
}

extension KeyedDecodingContainer {
    public func decode(_ type: ISODateTimeUTCCodable.Type, forKey key: Self.Key) throws -> ISODateTimeUTCCodable {
        try decodeIfPresent(type, forKey: key) ?? ISODateTimeUTCCodable(wrappedValue: nil)
    }
}

@propertyWrapper
public struct ISODateTimeCodable: Codable {
    public var wrappedValue: Date?
    
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try? container.decode(String.self) {
        case .some(let value):
            self.wrappedValue = DateFormatter.isoDateTime.date(from: value)
        case .none:
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(DateFormatter.isoDateTime.string(from: value))
        case .none:
            try container.encodeNil()
        }
    }
}

extension KeyedDecodingContainer {
    public func decode(_ type: ISODateTimeCodable.Type, forKey key: Self.Key) throws -> ISODateTimeCodable {
        try decodeIfPresent(type, forKey: key) ?? ISODateTimeCodable(wrappedValue: nil)
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

extension KeyedDecodingContainer {
    public func decode(_ type: ISODateCodable.Type, forKey key: Self.Key) throws -> ISODateCodable {
        try decodeIfPresent(type, forKey: key) ?? ISODateCodable(wrappedValue: nil)
    }
}

@propertyWrapper
public struct ISOYearCodable: Codable {
    public var wrappedValue: Date?
    
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try? container.decode(String.self) {
        case .some(let value):
            self.wrappedValue = DateFormatter.isoYear.date(from: value)
        case .none:
            self.wrappedValue = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(DateFormatter.isoYear.string(from: value))
        case .none:
            try container.encodeNil()
        }
    }
}

extension KeyedDecodingContainer {
    public func decode(_ type: ISOYearCodable.Type, forKey key: Self.Key) throws -> ISOYearCodable {
        try decodeIfPresent(type, forKey: key) ?? ISOYearCodable(wrappedValue: nil)
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

extension KeyedDecodingContainer {
    public func decode(_ type: ISOTimeCodable.Type, forKey key: Self.Key) throws -> ISOTimeCodable {
        try decodeIfPresent(type, forKey: key) ?? ISOTimeCodable(wrappedValue: nil)
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

extension KeyedDecodingContainer {
    public func decode(_ type: ISOTimeWithSecondsCodable.Type, forKey key: Self.Key) throws -> ISOTimeWithSecondsCodable {
        try decodeIfPresent(type, forKey: key) ?? ISOTimeWithSecondsCodable(wrappedValue: nil)
    }
}
