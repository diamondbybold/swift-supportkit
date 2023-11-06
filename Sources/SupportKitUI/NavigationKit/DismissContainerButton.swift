import SwiftUI

public struct DismissContainerButton<Label>: View where Label: View {
    private let label: Label
    private let withConfirmation: Bool
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    public init(_ titleKey: LocalizedStringKey, withConfirmation: Bool = false) where Label == Text {
        self.label = Text(titleKey)
        self.withConfirmation = withConfirmation
    }
    
    public init(withConfirmation: Bool = false, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.withConfirmation = withConfirmation
    }
    
    public init(image: String, withConfirmation: Bool = false) where Label == Image {
        self.label = Image(image)
        self.withConfirmation = withConfirmation
    }
    
    public init(systemImage: String, withConfirmation: Bool = false) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.withConfirmation = withConfirmation
    }
    
    public var body: some View {
        Button {
            navigationContext.dismiss(withConfirmation: withConfirmation)
        } label: {
            label
        }
    }
}
