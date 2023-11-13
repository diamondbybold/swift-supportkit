import SwiftUI

public struct DismissContainerButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    public init(_ titleKey: LocalizedStringKey, role: ButtonRole? = nil) where Label == Text {
        self.label = Text(titleKey)
        self.role = role
    }
    
    public init(role: ButtonRole? = nil, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
    }
    
    public init(image: String, role: ButtonRole? = nil) where Label == Image {
        self.label = Image(image)
        self.role = role
    }
    
    public init(systemImage: String, role: ButtonRole? = nil) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
    }
    
    public var body: some View {
        Button(role: role) {
            navigationContext.dismiss()
        } label: {
            label
        }
    }
}
