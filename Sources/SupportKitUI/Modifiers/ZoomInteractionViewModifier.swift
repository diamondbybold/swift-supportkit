import SwiftUI

struct ZoomInteractionViewModifier: ViewModifier {
    @State private var currentAmount: CGFloat = 0.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(1.0 + currentAmount)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in currentAmount = value - 1.0 }
                    .onEnded { _ in withAnimation(.interactiveSpring) { currentAmount = 0.0 } }
            )
    }
}

extension View {
    public func zoomInteraction() -> some View {
        self.modifier(ZoomInteractionViewModifier())
    }
}
