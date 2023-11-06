import Foundation

extension Decimal {
    public var double: Double { Double(truncating: self as NSNumber) }
}
