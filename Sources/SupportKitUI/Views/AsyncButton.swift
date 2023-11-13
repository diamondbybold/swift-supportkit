import SwiftUI

public struct AsyncButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    private let action: () async -> Void
    
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                action: @escaping () async -> Void) where Label == Text {
        self.label = Text(titleKey)
        self.role = role
        self.action = action
    }
    
    public init(role: ButtonRole? = nil,
                action: @escaping () async -> Void,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.action = action
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                action: @escaping () async -> Void) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.action = action
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                action: @escaping () async -> Void) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.action = action
    }
    
    public var body: some View {
        Button(role: role) {
            Task {
                await action()
            }
        } label: {
            label
        }
    }
}
