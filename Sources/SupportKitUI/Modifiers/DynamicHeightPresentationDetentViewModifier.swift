import SwiftUI

struct DynamicHeightPresentationDetentViewModifier: ViewModifier {
    @State private var size: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .contentSize($size)
            .presentationDetents([.height(size.height)])
    }
}

extension View {
    public func dynamicHeightPresentationDetent() -> some View {
        self.modifier(DynamicHeightPresentationDetentViewModifier())
    }
}
