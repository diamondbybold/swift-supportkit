import SwiftUI

struct ExpandableViewModifier: ViewModifier {
    let label: LocalizedStringKey
    let maxHeight: CGFloat
    let backgroundColor: Color
    
    @State private var expanded: Bool = false
    
    func body(content: Content) -> some View {
        ViewThatFits(in: .vertical) {
            content
            
            content
                .overlay(alignment: .bottomTrailing) {
                    HStack(spacing: 0) {
                        LinearGradient(colors: [.clear, backgroundColor], startPoint: .leading, endPoint: .trailing)
                            .frame(width: 50)
                        
                        Button(label) { withAnimation { expanded = true } }
                            .background(backgroundColor)
                    }
                    .fixedSize()
                }
        }
        .frame(maxHeight: expanded ? nil : maxHeight)
        .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    public func expandable(_ label: LocalizedStringKey, maxHeight: CGFloat, backgroundColor: Color) -> some View {
        self.modifier(ExpandableViewModifier(label: label, maxHeight: maxHeight, backgroundColor: backgroundColor))
    }
}
