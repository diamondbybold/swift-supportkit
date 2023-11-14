import SwiftUI

public struct ConfirmationButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let actions: () -> any View
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    public init(_ label: LocalizedStringKey,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actions: @escaping () -> any View) where Label == Text {
        self.label = Text(label)
        self.role = role
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    public init(role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actions: @escaping () -> any View,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actions: @escaping () -> any View) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actions: @escaping () -> any View) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    public var body: some View {
        Button(role: role) {
            navigationContext.alert(title: title,
                                    message: message,
                                    confirmation: true,
                                    actions: actions)
        } label: {
            label
        }
    }
}
