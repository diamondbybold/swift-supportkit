import SwiftUI

public struct NavigationButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    private let destination: NavigationContext.Destination
    private let disableTransition: Bool
    private let content: () -> any View
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                destination: NavigationContext.Destination,
                disableTransition: Bool = false,
                @ViewBuilder content: @escaping () -> any View) where Label == Text {
        self.label = Text(titleKey)
        self.role = role
        self.destination = destination
        self.disableTransition = disableTransition
        self.content = content
    }
    
    public init(role: ButtonRole? = nil,
                destination: NavigationContext.Destination,
                disableTransition: Bool = false,
                @ViewBuilder content: @escaping () -> any View,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.destination = destination
        self.disableTransition = disableTransition
        self.content = content
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                destination: NavigationContext.Destination,
                disableTransition: Bool = false,
                @ViewBuilder content: @escaping () -> any View) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.destination = destination
        self.disableTransition = disableTransition
        self.content = content
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                destination: NavigationContext.Destination,
                disableTransition: Bool = false,
                @ViewBuilder content: @escaping () -> any View) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.destination = destination
        self.disableTransition = disableTransition
        self.content = content
    }
    
    public var body: some View {
        Button(role: role) {
            navigationContext.destination(destination, disableTransition: disableTransition, content: content)
        } label: {
            label
        }
    }
}
