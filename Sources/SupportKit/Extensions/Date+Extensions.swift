import Foundation

extension Date {
    public static var startOfToday: Date { Calendar.current.startOfDay(for: .now) }
    
    public static var endOfToday: Date { Calendar.current.endOfDay(for: .now) }
    
    public func hasExpired(in interval: TimeInterval) -> Bool {
        Date(timeIntervalSinceNow:-interval) > self
    }
    
    public var isoDateTimeUTCString: String {
        DateFormatter.isoDateTimeUTC.string(from: self)
    }
    
    public var isoDateTimeString: String {
        DateFormatter.isoDateTime.string(from: self)
    }
    
    public var isoDateString: String {
        DateFormatter.isoDate.string(from: self)
    }
    
    public var isoYearString: String {
        DateFormatter.isoYear.string(from: self)
    }
    
    public var isoYearMonthString: String {
        DateFormatter.isoYearMonth.string(from: self)
    }
    
    public var isoTimeString: String {
        DateFormatter.isoTime.string(from: self)
    }
    
    public var isoTimeWithSecondsString: String {
        DateFormatter.isoTimeWithSeconds.string(from: self)
    }
}
