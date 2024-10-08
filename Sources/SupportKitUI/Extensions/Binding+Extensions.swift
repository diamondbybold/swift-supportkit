import SwiftUI

extension Binding where Value == Bool {
    public static func toggle(isSelected: Bool,
                              onSelect: @Sendable @escaping () -> Void,
                              onUnselect: @Sendable @escaping () -> Void) -> Binding<Value> {
        Binding {
            isSelected
        } set: {
            if $0 { onSelect() }
            else { onUnselect() }
        }
    }
    
    public static func check<T: Equatable & Sendable>(value: T, set: Binding<Set<T>>) -> Binding<Value> {
        Binding {
            set.wrappedValue.contains(value)
        } set: {
            if $0 { set.wrappedValue.insert(value) }
            else { set.wrappedValue.remove(value) }
        }
    }
    
    public static func radio<T: Equatable & Sendable>(value: T?, currentValue: Binding<T?>) -> Binding<Value> {
        Binding {
            value == currentValue.wrappedValue
        } set: { _ in
            currentValue.wrappedValue = value
        }
    }
    
    public static func present<T: Sendable>(value: Binding<T?>) -> Binding<Value> {
        Binding {
            value.wrappedValue != nil
        } set: {
            if !$0 { value.wrappedValue = nil }
        }
    }
}

extension Binding where Value: Sendable {
    public func onChange(_ handler: @Sendable @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
    
    public func onChange(_ handler: @Sendable @escaping () async -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                Task {
                    await handler()
                }
            }
        )
    }
    
    public func onChange(_ handler: @Sendable @escaping (Value, Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                let oldValue = self.wrappedValue
                self.wrappedValue = newValue
                handler(newValue, oldValue)
            }
        )
    }
    
    public func onChange(_ handler: @Sendable @escaping (Value, Value) async -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                let oldValue = self.wrappedValue
                self.wrappedValue = newValue
                Task {
                    await handler(newValue, oldValue)
                }
            }
        )
    }
}

public func ??<T: Sendable>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
