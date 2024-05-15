import SwiftUI
import SupportKit

public struct PopoverButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    private let content: () -> any View
    
    @State private var popover: NavigationContext.DestinationData? = nil
    
    @Environment(\.analyticsContextIdentifier) private var analyticsContextIdentifier: String
    @Environment(\.analyticsScreenIdentifier) private var analyticsScreenIdentifier: String
    @Environment(\.analyticsActionLog) private var analyticsActionLog: AnalyticsActionLog?
    
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                @ViewBuilder content: @escaping () -> any View) where Label == Text {
        self.label = Text(titleKey)
        self.role = role
        self.content = content
    }
    
    public init(role: ButtonRole? = nil,
                disableTransition: Bool = false,
                @ViewBuilder content: @escaping () -> any View,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.content = content
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                @ViewBuilder content: @escaping () -> any View) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.content = content
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                @ViewBuilder content: @escaping () -> any View) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.content = content
    }
    
    public var body: some View {
        Button(role: role) {
            if popover == nil {
                if let analyticsActionLog {
                    logActionEvent(analyticsActionLog.name,
                                   identifier: analyticsActionLog.identifier,
                                   screenIdentifier: analyticsScreenIdentifier,
                                   contextIdentifier: analyticsContextIdentifier,
                                   parameters: analyticsActionLog.parameters)
                }
                
                popover = NavigationContext.DestinationData(content: content)
            } else {
                popover = nil
            }
        } label: {
            label
        }
        .popover(item: $popover) { item in
            AnyView(item.content())
        }
    }
}
