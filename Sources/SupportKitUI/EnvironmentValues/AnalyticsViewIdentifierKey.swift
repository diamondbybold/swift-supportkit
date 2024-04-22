import SwiftUI

struct AnalyticsViewIdentifierKey: EnvironmentKey {
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

extension EnvironmentValues {
    public var analyticsViewIdentifier: String {
        get { self[AnalyticsViewIdentifierKey.self] }
        set { self[AnalyticsViewIdentifierKey.self] = newValue }
    }
}
