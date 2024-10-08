import SwiftUI

struct ContentSizeViewModifier: ViewModifier {
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
    public func contentSize(_ size: Binding<CGSize>) -> some View {
        self.modifier(ContentSizeViewModifier(size: size))
    }
}

struct SizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
