import Foundation

public struct ConstrainedIntegerParseStrategy: ParseStrategy {
    public func parse(_ value: String) throws -> Int? {
        try? Int(value, strategy: IntegerParseStrategy(format: .number))
    }
}

public struct ConstrainedIntegerFormatStyle: ParseableFormatStyle {
    public var parseStrategy = ConstrainedIntegerParseStrategy()
    public let range: ClosedRange<Int>
    
    public func format(_ value: Int?) -> String {
        guard let value else { return "" }
        return min(max(value, range.lowerBound), range.upperBound).formatted(.number)
    }
}

extension FormatStyle where Self == ConstrainedIntegerFormatStyle {
    public static func constrainedNumber(_ range: ClosedRange<Int>) -> Self { .init(range: range) }
}

public struct ConstrainedDecimalParseStrategy: ParseStrategy {
    public func parse(_ value: String) throws -> Decimal? {
        try? Decimal(value, strategy: Decimal.ParseStrategy(format: .number))
    }
}

public struct ConstrainedDecimalFormatStyle: ParseableFormatStyle {
    public var parseStrategy = ConstrainedDecimalParseStrategy()
    public let range: ClosedRange<Decimal>
    
    public func format(_ value: Decimal?) -> String {
        guard let value else { return "" }
        return min(max(value, range.lowerBound), range.upperBound).formatted(.number)
    }
}

extension FormatStyle where Self == ConstrainedDecimalFormatStyle {
    public static func constrainedNumber(_ range: ClosedRange<Decimal>) -> Self { .init(range: range) }
}
