import SwiftUI

struct ScrollToViewModifier: ViewModifier {
    @Namespace private var scrollToID
    
    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .id(scrollToID)
                .onAppear {
                    proxy.scrollTo(scrollToID)
                }
        }
    }
}

struct ScrollToOnChangeViewModifier<Value: Equatable>: ViewModifier {
    let value: Value
    @Namespace private var scrollToID
    
    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .id(scrollToID)
                .onAppear {
                    proxy.scrollTo(scrollToID)
                }
                .onChange(of: value) { newValue in
                    proxy.scrollTo(scrollToID)
                }
        }
    }
}

extension View {
    public func scrollTo() -> some View {
        self.modifier(ScrollToViewModifier())
    }
    
    public func scrollToOnChange<Value: Equatable>(_ value: Value) -> some View {
        self.modifier(ScrollToOnChangeViewModifier(value: value))
    }
}
