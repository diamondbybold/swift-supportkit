import SupportKit
import SwiftUI

struct AnalyticsScreenEventKey: EnvironmentKey {
    static let defaultValue: AnalyticsEvent? = nil
}

extension EnvironmentValues {
    public var analyticsScreenEvent: AnalyticsEvent? {
        get { self[AnalyticsScreenEventKey.self] }
        set { self[AnalyticsScreenEventKey.self] = newValue }
    }
}
