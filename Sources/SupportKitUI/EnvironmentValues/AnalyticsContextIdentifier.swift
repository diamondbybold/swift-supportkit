import SwiftUI

struct AnalyticsContextIdentifierKey: EnvironmentKey {
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

extension EnvironmentValues {
    public var analyticsContextIdentifier: String {
        get { self[AnalyticsContextIdentifierKey.self] }
        set { self[AnalyticsContextIdentifierKey.self] = newValue }
    }
}
