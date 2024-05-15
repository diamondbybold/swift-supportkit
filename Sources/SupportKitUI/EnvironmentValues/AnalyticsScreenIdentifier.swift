import SwiftUI

struct AnalyticsScreenIdentifierKey: EnvironmentKey {
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

extension EnvironmentValues {
    public var analyticsScreenIdentifier: String {
        get { self[AnalyticsScreenIdentifierKey.self] }
        set { self[AnalyticsScreenIdentifierKey.self] = newValue }
    }
}
