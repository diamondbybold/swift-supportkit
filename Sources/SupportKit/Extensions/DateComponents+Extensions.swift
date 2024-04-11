import Foundation

extension DateComponents {
    public func isSameYear(as components: DateComponents) -> Bool {
        year == components.year
    }
    
    public func isSameMonth(as components: DateComponents) -> Bool {
        year == components.year && month == components.month
    }
    
    public func isSameDay(as components: DateComponents) -> Bool {
        year == components.year && month == components.month && day == components.day
    }
}
