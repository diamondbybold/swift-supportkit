import SwiftUI

public struct ConfirmationDismissContainerButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let actionLabel: LocalizedStringKey
    private let actionRole: ButtonRole?
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    public init(_ label: LocalizedStringKey,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                actionRole: ButtonRole? = nil) where Label == Text {
        self.label = Text(label)
        self.role = role
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.actionRole = actionRole
    }
    
    public init(role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                actionRole: ButtonRole? = nil,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.actionRole = actionRole
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                actionRole: ButtonRole? = nil) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.actionRole = actionRole
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                actionRole: ButtonRole? = nil) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.actionRole = actionRole
    }
    
    public var body: some View {
        ConfirmationButton(role: role,
                           title: title,
                           message: message,
                           actionLabel: actionLabel,
                           actionRole: actionRole) {
            navigationContext.dismiss()
        } label: {
            label
        }
    }
}
