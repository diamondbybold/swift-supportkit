import Foundation

public var sharedAnalyticsObject: (any AnalyticsProtocol)? = nil

public protocol AnalyticsProtocol: AnyObject {
    var userIdentifier: String? { get set }
    
    func logEvent(_ event: AnalyticsEvent, name: String, identifier: String?, parameters: [String: Any?]?)
}

public enum AnalyticsEvent {
    case view
    case action(String)
    case data
}
