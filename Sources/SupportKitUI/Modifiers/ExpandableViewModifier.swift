import SwiftUI

struct ExpandableViewModifier: ViewModifier {
    let label: LocalizedStringKey
    let maxHeight: CGFloat
    
    @State private var expanded: Bool = false
    
    func body(content: Content) -> some View {
        ViewThatFits(in: .vertical) {
            content
            
            content
                .overlay(alignment: .bottomTrailing) {
                    HStack(spacing: 0) {
                        LinearGradient(colors: [.clear, .white], startPoint: .leading, endPoint: .trailing)
                            .frame(width: 50)
                        
                        Button(label) { expanded = true }
                            .background(.white)
                    }
                    .fixedSize()
                }
        }
        .frame(maxHeight: expanded ? nil : maxHeight)
        .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    public func expandable(_ label: LocalizedStringKey, maxHeight: CGFloat) -> some View {
        self.modifier(ExpandableViewModifier(label: label, maxHeight: maxHeight))
    }
}
