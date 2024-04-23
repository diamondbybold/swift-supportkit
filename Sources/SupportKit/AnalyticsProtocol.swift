import Foundation

public protocol AnalyticsProtocol: AnyObject {
    var deviceIdentifier: String? { get set }
    var userIdentifier: String? { get set }
    
    func logViewEvent(_ name: String, identifier: String, parameters: [String: Any?]?)
    func logActionEvent(_ name: String, identifier: String, viewIdentifier: String, parameters: [String: Any?]?)
    func logDataEvent(_ name: String, parameters: [String: Any?]?)
}

// MARK: - Global functions
public var sharedAnalyticsObject: (any AnalyticsProtocol)? = nil

public func logViewEvent(_ name: String, identifier: String, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logViewEvent(name, identifier: identifier, parameters: parameters)
}

public func logActionEvent(_ name: String, identifier: String, viewIdentifier: String, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logActionEvent(name, identifier: identifier, viewIdentifier: viewIdentifier, parameters: parameters)
}

public func logDataEvent(_ name: String, parameters: [String: Any?]? = nil) {
    sharedAnalyticsObject?.logDataEvent(name, parameters: parameters)
}
