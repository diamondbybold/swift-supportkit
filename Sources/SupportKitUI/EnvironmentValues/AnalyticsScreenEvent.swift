import SupportKit
import SwiftUI

struct AnalyticsScreenEventKey: EnvironmentKey {
    static var defaultValue: AnalyticsEvent? = nil
}

extension EnvironmentValues {
    public var analyticsScreenEvent: AnalyticsEvent? {
        get { self[AnalyticsScreenEventKey.self] }
        set { self[AnalyticsScreenEventKey.self] = newValue }
    }
}
