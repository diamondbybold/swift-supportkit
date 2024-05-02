import Foundation

public protocol AnalyticsProtocol: AnyObject {
    var deviceIdentifier: String? { get set }
    var userIdentifier: String? { get set }
    var screenIdentifier: String? { get set }
    
    func logScreenEvent(_ identifier: String, parameters: [String: Any?]?)
    func logActionEvent(_ name: String, identifier: String, screenIdentifier: String?, parameters: [String: Any?]?)
    func logDataEvent(_ name: String, parameters: [String: Any?]?)
    func logEvent(_ name: String, parameters: [String: Any?]?)
}

// MARK: - Global functions
public var sharedAnalyticsObject: (any AnalyticsProtocol)? = nil

public func logScreenEvent(_ identifier: String, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logScreenEvent(identifier, parameters: parameters)
}

public func logActionEvent(_ name: String, identifier: String, screenIdentifier: String? = nil, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logActionEvent(name, identifier: identifier, screenIdentifier: screenIdentifier, parameters: parameters)
}

public func logDataEvent(_ name: String, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logDataEvent(name, parameters: parameters)
}

public func logEvent(_ name: String, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logEvent(name, parameters: parameters)
}
