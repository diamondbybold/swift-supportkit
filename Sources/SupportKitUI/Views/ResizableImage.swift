import SwiftUI

public struct ResizableImage: View {
    private let name: String
    private let scaledToFill: Bool
    
    public init(_ name: String,
                scaledToFill: Bool = false) {
        self.name = name
        self.scaledToFill = scaledToFill
    }
    
    public var body: some View {
        if scaledToFill {
            Color.clear.overlay {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
        } else {
            Image(name)
                .resizable()
                .scaledToFit()
        }
    }
}
