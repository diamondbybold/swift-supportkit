import Foundation

public struct AnalyticsEvent {
    public let name: String
    public let parameters: [String: String]
    
    public init(name: String,
                parameters: [String: String]) {
        self.name = name
        self.parameters = parameters
    }
}

public protocol AnalyticsProtocol: AnyObject {
    var deviceIdentifier: String? { get set }
    var userIdentifier: String? { get set }
    var contextData: [String: String] { get set }
    var screenEvent: AnalyticsEvent? { get set }
    
    func logScreenEvent(_ event: AnalyticsEvent)
    func logActionEvent(_ event: AnalyticsEvent)
}

// MARK: - Global functions
public var sharedAnalyticsObject: (any AnalyticsProtocol)? = nil

public func logScreenEvent(_ event: AnalyticsEvent) {
    sharedAnalyticsObject?.logScreenEvent(event)
}

public func logScreenEvent(name: String,
                           parameters: [String: String]) {
    sharedAnalyticsObject?.logScreenEvent(.init(name: name, parameters: parameters))
}

public func logActionEvent(_ event: AnalyticsEvent) {
    sharedAnalyticsObject?.logActionEvent(event)
}

public func logActionEvent(name: String,
                           parameters: [String: String]) {
    sharedAnalyticsObject?.logActionEvent(.init(name: name, parameters: parameters))
}
