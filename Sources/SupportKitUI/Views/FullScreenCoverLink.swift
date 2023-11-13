import SwiftUI

public struct FullScreenCoverLink<Label, Destination>: View where Label: View, Destination: View {
    private let label: Label
    private let animation: Bool
    private let destination: () -> Destination
    private var onDismiss: (() -> Void)? = nil
    
    @State private var show: Bool = false
    
    public init(_ titleKey: LocalizedStringKey, animation: Bool = true, @ViewBuilder destination: @escaping () -> Destination, onDismiss: (() -> Void)? = nil) where Label == Text {
        self.label = Text(titleKey)
        self.animation = animation
        self.destination = destination
        self.onDismiss = onDismiss
    }
    
    public init(animation: Bool = true, @ViewBuilder destination: @escaping () -> Destination, @ViewBuilder label: () -> Label, onDismiss: (() -> Void)? = nil) {
        self.label = label()
        self.animation = animation
        self.destination = destination
        self.onDismiss = onDismiss
    }
    
    public init(image: String, animation: Bool = true, @ViewBuilder destination: @escaping () -> Destination, onDismiss: (() -> Void)? = nil) where Label == Image {
        self.label = Image(image)
        self.animation = animation
        self.destination = destination
        self.onDismiss = onDismiss
    }
    
    public init(systemImage: String, animation: Bool = true, @ViewBuilder destination: @escaping () -> Destination, onDismiss: (() -> Void)? = nil) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.animation = animation
        self.destination = destination
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        Button {
            show = true
        } label: {
            label
        }
        .fullScreenCover(isPresented: $show, onDismiss: onDismiss) {
            destination()
                .imageScale(.medium)
        }
        .transaction { transaction in
            transaction.disablesAnimations = !animation
        }
    }
}
