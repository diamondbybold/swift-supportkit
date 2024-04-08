import Foundation

extension Date {
    public func hasExpired(in interval: TimeInterval) -> Bool {
        Date(timeIntervalSinceNow:-interval) > self
    }
    
    public var isoDateTimeString: String {
        DateFormatter.isoDateTime.string(from: self)
    }
    
    public var isoLocalDateTimeWithTimeZoneString: String {
        DateFormatter.isoLocalDateTimeWithTimeZone.string(from: self)
    }    
    
    public var isoDateString: String {
        DateFormatter.isoDate.string(from: self)
    }
    
    public var isoTimeString: String {
        DateFormatter.isoTime.string(from: self)
    }
    
    public var isoTimeWithSecondsString: String {
        DateFormatter.isoTimeWithSeconds.string(from: self)
    }
}
