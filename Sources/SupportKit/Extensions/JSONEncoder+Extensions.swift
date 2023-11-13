import Foundation

extension JSONEncoder {
    public static let camelCase: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    public static let snakeCase: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

extension JSONEncoder {
    enum JSONValue: Encodable {
        case null
        case encodable(Encodable)
        case string(String)
        case int(Int)
        case double(Double)
        case decimal(Decimal)
        case bool(Bool)
        case object([String: JSONValue])
        case array([JSONValue])
        
        init(any: Any) {
            if let value = any as? String {
                self = .string(value)
            } else if let value = any as? Int {
                self = .int(value)
            } else if let value = any as? Double {
                self = .double(value)
            } else if let value = any as? Decimal {
                self = .decimal(value)
            } else if let value = any as? Bool {
                self = .bool(value)
            } else if let json = any as? [String: Any] {
                var dict: [String: JSONValue] = [:]
                for (key, value) in json {
                    dict[key] = JSONValue(any: value)
                }
                self = .object(dict)
            } else if let jsonArray = any as? [Any] {
                let array = jsonArray.compactMap { JSONValue(any: $0) }
                self = .array(array)
            } else if let encodable = any as? Encodable {
                self = .encodable(encodable)
            } else {
                self = .null
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .null: try container.encodeNil()
            case .string(let string): try container.encode(string)
            case .int(let int): try container.encode(int)
            case .double(let double): try container.encode(double)
            case .decimal(let decimal): try container.encode(decimal)
            case .bool(let bool): try container.encode(bool)
            case .object(let object): try container.encode(object)
            case .array(let array): try container.encode(array)
            case .encodable(let encodable): try container.encode(encodable)
            }
        }
    }
    
    public func encodeAny(_ any: Any) throws -> Data {
        let value = JSONValue(any: any)
        return try encode(value)
    }
}
