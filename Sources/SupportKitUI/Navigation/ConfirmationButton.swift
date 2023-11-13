import SwiftUI

public struct ConfirmationButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let actionLabel: LocalizedStringKey
    private let actionRole: ButtonRole?
    private let action: () -> Void
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    public init(_ label: LocalizedStringKey,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                actionRole: ButtonRole? = nil,
                action: @escaping () -> Void) where Label == Text {
        self.label = Text(label)
        self.role = role
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.actionRole = actionRole
        self.action = action
    }
    
    public init(role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                actionRole: ButtonRole? = nil,
                action: @escaping () -> Void,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.actionRole = actionRole
        self.action = action
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                actionRole: ButtonRole? = nil,
                action: @escaping () -> Void) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.actionRole = actionRole
        self.action = action
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                actionRole: ButtonRole? = nil,
                action: @escaping () -> Void) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.actionRole = actionRole
        self.action = action
    }
    
    public var body: some View {
        Button(role: role) {
            navigationContext.confirmation(title: title,
                                           message: message,
                                           actionLabel: actionLabel,
                                           actionRole: actionRole,
                                           action: action)
        } label: {
            label
        }
    }
}
