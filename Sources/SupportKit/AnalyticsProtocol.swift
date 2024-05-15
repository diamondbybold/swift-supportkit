import Foundation

public protocol AnalyticsProtocol: AnyObject {
    var deviceIdentifier: String? { get set }
    var userIdentifier: String? { get set }
    var contextIdentifier: String? { get set }
    var screenIdentifier: String? { get set }
    
    func logScreenEvent(_ identifier: String,
                        parameters: [String: String]?)
    
    func logActionEvent(_ name: String,
                        identifier: String,
                        screenIdentifier: String?,
                        contextIdentifier: String?,
                        parameters: [String: String]?)
    
    func logDataEvent(_ name: String,
                      parameters: [String: String]?)
}

// MARK: - Global functions
public var sharedAnalyticsObject: (any AnalyticsProtocol)? = nil

public func logScreenEvent(_ identifier: String,
                           parameters: [String: String]? = nil) {
    sharedAnalyticsObject?.logScreenEvent(identifier,
                                          parameters: parameters)
}

public func logActionEvent(_ name: String,
                           identifier: String,
                           screenIdentifier: String? = nil,
                           contextIdentifier: String? = nil,
                           parameters: [String: String]? = nil) {
    sharedAnalyticsObject?.logActionEvent(name,
                                          identifier: identifier,
                                          screenIdentifier: screenIdentifier,
                                          contextIdentifier: contextIdentifier,
                                          parameters: parameters)
}

public func logDataEvent(_ name: String,
                         parameters: [String: String]? = nil) {
    sharedAnalyticsObject?.logDataEvent(name,
                                        parameters: parameters)
}
