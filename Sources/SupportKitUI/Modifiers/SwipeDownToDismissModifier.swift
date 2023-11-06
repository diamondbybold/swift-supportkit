import SwiftUI

struct SwipeDownToDismissModifier: ViewModifier {
    var onDismiss: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1
    @State private var opacity: CGFloat = 1
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .offset(y: offset.height)
            .opacity(opacity)
            .animation(.interactiveSpring(), value: offset)
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { gesture in
                        let translation = gesture.translation
                        offset = translation
                        scale = 1 - min(abs(translation.height), 200) / 1000
                        opacity = 1 - min(abs(translation.height), 200) / 300
                    }
                    .onEnded { _ in
                        if offset.height > 100 {
                            onDismiss()
                        } else if offset != .zero {
                            offset = .zero
                            scale = 1
                            opacity = 1
                        }
                    }
            )
    }
}

extension View {
    public func swipeDownToDismiss(_ onDismiss: @escaping () -> Void) -> some View {
        self.modifier(SwipeDownToDismissModifier(onDismiss: onDismiss))
    }
}
