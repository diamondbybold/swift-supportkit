import SwiftUI

public struct DismissButton<Label>: View where Label: View {
    private let label: Label
    
    @Environment(\.dismiss) private var dismiss
    
    public init(_ titleKey: LocalizedStringKey) where Label == Text {
        self.label = Text(titleKey)
    }
    
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }
    
    public init(image: String) where Label == Image {
        self.label = Image(image)
    }
    
    public init(systemImage: String) where Label == Image {
        self.label = Image(systemName: systemImage)
    }
    
    public var body: some View {
        Button {
            dismiss()
        } label: {
            label
        }
    }
}
