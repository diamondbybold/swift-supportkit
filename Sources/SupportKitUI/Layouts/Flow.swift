import SwiftUI

public struct Flow: Layout {
    private let spacing: CGFloat
    
    public struct Cache {
        let sizes: [CGSize]
    }
    
    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    public func makeCache(subviews: Subviews) -> Cache {
        .init(sizes: subviews.map { $0.sizeThatFits(.unspecified) })
    }
    
    public func updateCache(_ cache: inout Cache, subviews: Subviews) {
        cache = .init(sizes: subviews.map { $0.sizeThatFits(.unspecified) })
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        var totalWidth: CGFloat = 0.0
        var totalHeight: CGFloat = 0.0
        
        var lineWidth: CGFloat = 0.0
        var lineHeight: CGFloat = 0.0
        
        for (index, _) in subviews.enumerated() {
            var subviewSize = cache.sizes[index]
            
            // Limit subview width to proposal width
            if let proposalWidth = proposal.width { subviewSize.width = min(subviewSize.width, proposalWidth) }
            
            if lineWidth + subviewSize.width > proposal.width ?? 0.0 {
                totalHeight += lineHeight + spacing
                lineWidth = 0.0
                lineHeight = 0.0
            }
            
            lineWidth += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
            
            totalWidth = max(totalWidth, lineWidth)
        }
        
        totalWidth -= spacing
        totalHeight += lineHeight
        
        return .init(width: totalWidth, height: totalHeight)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var lineX: CGFloat = 0.0
        var lineY: CGFloat = 0.0
        
        var lineHeight: CGFloat = 0.0
        
        for (index, subview) in subviews.enumerated() {
            var subviewSize = cache.sizes[index]
            
            // Limit subview width to proposal width
            if let proposalWidth = proposal.width { subviewSize.width = min(subviewSize.width, proposalWidth) }
            
            if lineX + subviewSize.width > bounds.width {
                lineX = 0.0
                lineY += lineHeight + spacing
                lineHeight = subviewSize.height
            }
            
            subview.place(
                at: CGPoint(x: bounds.origin.x + lineX,
                            y: bounds.origin.y + lineY),
                anchor: .topLeading,
                proposal: ProposedViewSize(subviewSize)
            )
            
            lineX += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
        }
    }
}
