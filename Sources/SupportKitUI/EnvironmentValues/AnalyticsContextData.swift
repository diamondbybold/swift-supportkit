import SwiftUI

struct AnalyticsContextDataKey: EnvironmentKey {
    static var defaultValue: [String: String] = [:]
}

extension EnvironmentValues {
    public var analyticsContextData: [String: String] {
        get { self[AnalyticsContextDataKey.self] }
        set {
            let value = analyticsContextData.merging(newValue, uniquingKeysWith: ({ old, new in new }))
            self[AnalyticsContextDataKey.self] = value
        }
    }
}
