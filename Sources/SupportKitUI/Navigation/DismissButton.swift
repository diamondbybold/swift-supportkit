import SwiftUI

public struct DismissButton<Label>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    private let disableTransition: Bool
    private let action: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                disableTransition: Bool = false,
                action: @escaping () -> Void = { }) where Label == Text {
        self.label = Text(titleKey)
        self.role = role
        self.disableTransition = disableTransition
        self.action = action
    }
    
    public init(role: ButtonRole? = nil,
                disableTransition: Bool = false,
                action: @escaping () -> Void = { },
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.disableTransition = disableTransition
        self.action = action
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                disableTransition: Bool = false,
                action: @escaping () -> Void = { }) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.disableTransition = disableTransition
        self.action = action
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                disableTransition: Bool = false,
                action: @escaping () -> Void = { }) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.disableTransition = disableTransition
        self.action = action
    }
    
    public var body: some View {
        Button(role: role) {
            action()
            
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
