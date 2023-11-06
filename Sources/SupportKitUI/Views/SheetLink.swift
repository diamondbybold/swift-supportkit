import SwiftUI

public struct SheetLink<Label, Destination>: View where Label: View, Destination: View {
    private let label: Label
    private let destination: Destination
    private var onDismiss: (() -> Void)? = nil
    
    @State private var show: Bool = false
    
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder destination: () -> Destination, onDismiss: (() -> Void)? = nil) where Label == Text {
        self.label = Text(titleKey)
        self.destination = destination()
        self.onDismiss = onDismiss
    }
    
    public init(@ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label, onDismiss: (() -> Void)? = nil) {
        self.label = label()
        self.destination = destination()
        self.onDismiss = onDismiss
    }
    
    public init(image: String, @ViewBuilder destination: () -> Destination, onDismiss: (() -> Void)? = nil) where Label == Image {
        self.label = Image(image)
        self.destination = destination()
        self.onDismiss = onDismiss
    }
    
    public init(systemImage: String, @ViewBuilder destination: () -> Destination, onDismiss: (() -> Void)? = nil) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.destination = destination()
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        Button {
            show = true
        } label: {
            label
        }
        .sheet(isPresented: $show, onDismiss: onDismiss) {
            destination
                .imageScale(.medium)
        }
    }
}
