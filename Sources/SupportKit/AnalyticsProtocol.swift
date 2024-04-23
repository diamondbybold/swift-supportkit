import Foundation

public var sharedAnalyticsObject: (any AnalyticsProtocol)? = nil

public protocol AnalyticsProtocol: AnyObject {
    var userIdentifier: String? { get set }
    
    func logEvent(_ event: AnalyticsEvent, name: String, identifier: String?, parameters: [String: Any?]?)
}

extension AnalyticsProtocol {
    public func logEvent(name: String, parameters: [String: Any?]? = nil) {
        logEvent(.data, name: name, identifier: nil, parameters: parameters)
    }
}

public enum AnalyticsEvent {
    case view
    case action(String)
    case data
}
