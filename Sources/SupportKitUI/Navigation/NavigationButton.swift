import SwiftUI

public struct NavigationButton<Label>: View where Label: View {
    private let label: Label
    private let destination: NavigationContext.Destination
    private let content: () -> any View
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    public init(_ titleKey: LocalizedStringKey,
                destination: NavigationContext.Destination,
                @ViewBuilder content: @escaping () -> any View) where Label == Text {
        self.label = Text(titleKey)
        self.destination = destination
        self.content = content
    }
    
    public init(destination: NavigationContext.Destination,
                @ViewBuilder content: @escaping () -> any View,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.destination = destination
        self.content = content
    }
    
    public init(image: String,
                destination: NavigationContext.Destination,
                @ViewBuilder content: @escaping () -> any View) where Label == Image {
        self.label = Image(image)
        self.destination = destination
        self.content = content
    }
    
    public init(systemImage: String,
                destination: NavigationContext.Destination,
                @ViewBuilder content: @escaping () -> any View) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.destination = destination
        self.content = content
    }
    
    public var body: some View {
        Button {
            navigationContext.destination(destination, content: content)
        } label: {
            label
        }
    }
}
