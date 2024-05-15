import SwiftUI
import SupportKit

public struct NavigationButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    private let destination: NavigationContext.Destination
    private let disableTransition: Bool
    private let action: () -> Void
    private let content: () -> any View
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    @Environment(\.analyticsContextIdentifier) private var analyticsContextIdentifier: String
    @Environment(\.analyticsScreenIdentifier) private var analyticsScreenIdentifier: String
    @Environment(\.analyticsActionLog) private var analyticsActionLog: AnalyticsActionLog?
    
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                destination: NavigationContext.Destination,
                disableTransition: Bool = false,
                action: @escaping () -> Void = { },
                @ViewBuilder content: @escaping () -> any View) where Label == Text {
        self.label = Text(titleKey)
        self.role = role
        self.destination = destination
        self.disableTransition = disableTransition
        self.action = action
        self.content = content
    }
    
    public init(role: ButtonRole? = nil,
                destination: NavigationContext.Destination,
                disableTransition: Bool = false,
                action: @escaping () -> Void = { },
                @ViewBuilder content: @escaping () -> any View,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.destination = destination
        self.disableTransition = disableTransition
        self.action = action
        self.content = content
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                destination: NavigationContext.Destination,
                disableTransition: Bool = false,
                action: @escaping () -> Void = { },
                @ViewBuilder content: @escaping () -> any View) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.destination = destination
        self.disableTransition = disableTransition
        self.action = action
        self.content = content
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                destination: NavigationContext.Destination,
                disableTransition: Bool = false,
                action: @escaping () -> Void = { },
                @ViewBuilder content: @escaping () -> any View) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.destination = destination
        self.disableTransition = disableTransition
        self.action = action
        self.content = content
    }
    
    public var body: some View {
        Button(role: role) {
            if let analyticsActionLog {
                logActionEvent(analyticsActionLog.name,
                               identifier: analyticsActionLog.identifier,
                               screenIdentifier: analyticsScreenIdentifier,
                               contextIdentifier: analyticsContextIdentifier,
                               parameters: analyticsActionLog.parameters)
            }
            
            action()
            navigationContext.destination(destination, disableTransition: disableTransition, content: content)
        } label: {
            label
        }
    }
}
