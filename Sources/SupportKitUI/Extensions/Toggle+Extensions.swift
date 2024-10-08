import SwiftUI

extension Toggle {
    public init(isSelected: Bool,
                onSelect: @Sendable @escaping () -> Void,
                onUnselect: @Sendable @escaping () -> Void,
                @ViewBuilder label: () -> Label) {
        self.init(isOn: .toggle(isSelected: isSelected, onSelect: onSelect, onUnselect: onUnselect),
                  label: label)
    }
    
    public init(_ title: String,
                isSelected: Bool,
                onSelect: @Sendable @escaping () -> Void,
                onUnselect: @Sendable @escaping () -> Void) where Label == Text {
        self.init(LocalizedStringKey(title),
                  isOn: .toggle(isSelected: isSelected, onSelect: onSelect, onUnselect: onUnselect))
    }
    
    public init<V: Equatable & Sendable>(value: V?, currentValue: Binding<V?>, @ViewBuilder label: () -> Label) {
        self.init(isOn: .radio(value: value, currentValue: currentValue),
                  label: label)
    }
    
    public init<V: Equatable & Sendable>(_ title: String, value: V?, currentValue: Binding<V?>) where Label == Text {
        self.init(LocalizedStringKey(title),
                  isOn: .radio(value: value, currentValue: currentValue))
    }
    
    public init<V: Equatable & Sendable>(value: V, set: Binding<Set<V>>, @ViewBuilder label: () -> Label) {
        self.init(isOn: .check(value: value, set: set),
                  label: label)
    }
    
    public init<V: Equatable & Sendable>(_ title: String, value: V, set: Binding<Set<V>>) where Label == Text {
        self.init(LocalizedStringKey(title),
                  isOn: .check(value: value, set: set))
    }
}
