import SwiftUI

public struct StickyHeader<Content: View>: View {
    private let minHeight: CGFloat
    private let content: () -> Content
    
    public init(minHeight: CGFloat = 200,
                @ViewBuilder content: @escaping () -> Content) {
        self.minHeight = minHeight
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let isCompressing = proxy.frame(in: .global).minY <= 0
            content()
                .offset(y: isCompressing ? 0 : -proxy.frame(in: .global).minY)
                .frame(width: proxy.size.width, height: proxy.size.height + (isCompressing ? 0 : proxy.frame(in: .global).minY))
        }
        .frame(minHeight: minHeight)
    }
}
