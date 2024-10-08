import SwiftUI

public struct OffsetReader: View {
    @Binding var offset: CGPoint
    let coordinateSpace: AnyHashable
    
    public init(_ offset: Binding<CGPoint>, coordinateSpace: AnyHashable) {
        self._offset = offset
        self.coordinateSpace = coordinateSpace
    }
    
    public var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: OffsetKey.self, value: proxy.frame(in: .named(coordinateSpace)).origin)
        }
        .frame(height: 0)
        .onPreferenceChange(OffsetKey.self) { offset = $0 }
    }
}

struct OffsetKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}
