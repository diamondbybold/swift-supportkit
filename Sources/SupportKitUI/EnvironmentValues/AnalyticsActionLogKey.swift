import SwiftUI

public struct AnalyticsActionLog {
    let name: String
    let identifier: String
    let parameters: [String: Any?]?
}

struct AnalyticsActionLogKey: EnvironmentKey {
    static var defaultValue: AnalyticsActionLog? = nil
    
    static func reduce(value: inout AnalyticsActionLog, nextValue: () -> AnalyticsActionLog) {
        value = nextValue()
    }
}

extension EnvironmentValues {
    public var analyticsActionLog: AnalyticsActionLog? {
        get { self[AnalyticsActionLogKey.self] }
        set { self[AnalyticsActionLogKey.self] = newValue }
    }
}
