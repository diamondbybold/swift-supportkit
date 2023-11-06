import SwiftUI

extension View {
    public var shortScreen: Bool {
        let height = UIScreen.main.bounds.size.height
        
        if height < 812.0 {
            return true
        } else {
            return false
        }
    }
    
    @MainActor
    public func hideKeyboard() {
        _ = UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

extension View {
    public func withAnimationAsync(_ duration: Double, _ body: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(.linear(duration: duration)) {
                body()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
    
    public func withoutAnimation(_ body: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            body()
        }
    }
}

extension ViewModifier {
    public func withAnimationAsync(_ duration: Double, _ body: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(.linear(duration: duration)) {
                body()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
    
    public func withoutAnimation(_ body: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            body()
        }
    }
}

extension View {
    @ViewBuilder
    public func screenRelativeFrame(_ axes: Axis.Set,
                                    count: Int,
                                    span: Int,
                                    spacing: CGFloat,
                                    inset: CGFloat) -> some View {
        if axes == .vertical {
            let availableHeight = (UIScreen.main.bounds.height - (inset * 2.0) - (spacing * CGFloat(count - 1)))
            let rowHeight = (availableHeight / CGFloat(count))
            let itemHeight = (rowHeight * CGFloat(span)) + (CGFloat(span - 1) * spacing)
            self.frame(height: itemHeight)
        } else {
            let availableWidth = (UIScreen.main.bounds.width - (inset * 2.0) - (spacing * CGFloat(count - 1)))
            let columnWidth = (availableWidth / CGFloat(count))
            let itemWidth = (columnWidth * CGFloat(span)) + (CGFloat(span - 1) * spacing)
            self.frame(width: itemWidth)
        }
    }
}
