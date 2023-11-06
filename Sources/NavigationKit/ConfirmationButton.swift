import SwiftUI

public struct ConfirmationButton<Label>: View where Label: View {
    private let label: Label
    
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey?
    private let actionLabel: LocalizedStringKey
    private let action: () -> Void
    
    public init(_ label: LocalizedStringKey,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                action: @escaping () -> Void) where Label == Text {
        self.label = Text(label)
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.action = action
    }
    
    public init(title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                action: @escaping () -> Void,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.action = action
    }
    
    public init(image: String,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                action: @escaping () -> Void) where Label == Image {
        self.label = Image(image)
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.action = action
    }
    
    public init(symbol: String,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                actionLabel: LocalizedStringKey,
                action: @escaping () -> Void) where Label == Image {
        self.label = Image(systemName: symbol)
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            label
        }
    }
}
