import SwiftUI

public struct DismissButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    private let disableTransition: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                disableTransition: Bool = false) where Label == Text {
        self.label = Text(titleKey)
        self.role = role
        self.disableTransition = disableTransition
    }
    
    public init(role: ButtonRole? = nil,
                disableTransition: Bool = false,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.disableTransition = disableTransition
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                disableTransition: Bool = false) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.disableTransition = disableTransition
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                disableTransition: Bool = false) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.disableTransition = disableTransition
    }
    
    public var body: some View {
        Button(role: role) {
            var transaction = Transaction()
            transaction.disablesAnimations = disableTransition
            withTransaction(transaction) {
                dismiss()
            }
        } label: {
            label
        }
    }
}
