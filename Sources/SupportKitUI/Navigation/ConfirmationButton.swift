import SwiftUI
import SupportKit

public struct ConfirmationButton<Label, Action>: View where Label: View, Action: View {
    private let label: Label
    private let role: ButtonRole?
    
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let actions: () -> Action
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    @Environment(\.analyticsContextData) private var analyticsContextData: [String: String]
    @Environment(\.analyticsScreenEvent) private var analyticsScreenEvent: AnalyticsEvent?
    @Environment(\.analyticsActionEvent) private var analyticsActionEvent: AnalyticsEvent?
    
    public init(_ label: LocalizedStringKey,
                role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                @ViewBuilder actions: @escaping () -> Action) where Label == Text {
        self.label = Text(label)
        self.role = role
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    public init(role: ButtonRole? = nil,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                @ViewBuilder actions: @escaping () -> Action,
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
                @ViewBuilder actions: @escaping () -> Action) where Label == Image {
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
                @ViewBuilder actions: @escaping () -> Action) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    public var body: some View {
        Button(role: role) {
            
            
            if let analyticsActionEvent {
                logActionEvent(analyticsActionEvent)
            }
            
            navigationContext.alert(title: title,
                                    message: message,
                                    confirmation: true,
                                    actions: actions)
        } label: {
            label
        }
    }
}
