import Foundation

public protocol AnalyticsProtocol: AnyObject {
    var deviceIdentifier: String? { get set }
    var userIdentifier: String? { get set }
    var contextIdentifier: String? { get set }
    
    func logContextEvent(_ name: String, identifier: String, parameters: [String: Any?]?)
    func logActionEvent(_ name: String, identifier: String, contextIdentifier: String?, parameters: [String: Any?]?)
    func logDataEvent(_ name: String, parameters: [String: Any?]?)
    func logEvent(_ name: String, parameters: [String: Any?]?)
}

// MARK: - Global functions
public var sharedAnalyticsObject: (any AnalyticsProtocol)? = nil

public func logContextEvent(_ name: String, identifier: String, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logContextEvent(name, identifier: identifier, parameters: parameters)
}

public func logActionEvent(_ name: String, identifier: String, contextIdentifier: String? = nil, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logActionEvent(name, identifier: identifier, contextIdentifier: contextIdentifier, parameters: parameters)
}

public func logDataEvent(_ name: String, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logDataEvent(name, parameters: parameters)
}

public func logEvent(_ name: String, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logEvent(name, parameters: parameters)
}
