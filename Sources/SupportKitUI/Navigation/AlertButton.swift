import SwiftUI
import SupportKit

public struct AlertButton<Label, Action>: View where Label: View, Action: View {
    private let label: Label
    private let role: ButtonRole?
    
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let actions: () -> Action
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    @Environment(\.analyticsViewIdentifier) private var analyticsViewIdentifier: String
    @Environment(\.analyticsActionLog) private var analyticsActionLog: AnalyticsActionLog?
    
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
            navigationContext.alert(title: title,
                                    message: message,
                                    confirmation: false,
                                    actions: actions)
            
            if let analyticsActionLog {
                logEvent(.action(analyticsViewIdentifier),
                         name: analyticsActionLog.name,
                         identifier: analyticsActionLog.identifier,
                         parameters: analyticsActionLog.parameters)
            }
        } label: {
            label
        }
    }
}
