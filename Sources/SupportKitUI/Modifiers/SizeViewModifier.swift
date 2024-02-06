import SwiftUI

struct SizeViewModifier: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SizeKey.self, value: proxy.size)
                }
                .onPreferenceChange(SizeKey.self) { size = $0 }
            }
    }
}

extension View {
    public func size(_ size: Binding<CGSize>) -> some View {
        self.modifier(SizeViewModifier(size: size))
    }
}

struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
