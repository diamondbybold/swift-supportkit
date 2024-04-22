import Foundation

public protocol AnalyticsProtocol {
    func logEvent(_ event: AnalyticsEvent, name: String, parameters: [String: Any?]?)
}

public enum AnalyticsEvent {
    case view
    case action
    case data
    case success
    case failure
}
