import SwiftUI

public struct OffsetReader: View {
    @Binding public var point: CGPoint
    @Namespace public var coordinateSpace
    
    public var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: OffsetKey.self, value: proxy.frame(in: .named(coordinateSpace)).origin)
        }
        .frame(height: 0)
        .onPreferenceChange(OffsetKey.self) { point = $0 }
    }
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}
