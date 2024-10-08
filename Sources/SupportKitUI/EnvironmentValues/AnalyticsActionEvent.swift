import SupportKit
import SwiftUI

struct AnalyticsActionEventKey: EnvironmentKey {
    static let defaultValue: AnalyticsEvent? = nil
}

extension EnvironmentValues {
    public var analyticsActionEvent: AnalyticsEvent? {
        get { self[AnalyticsActionEventKey.self] }
        set { self[AnalyticsActionEventKey.self] = newValue }
    }
}
