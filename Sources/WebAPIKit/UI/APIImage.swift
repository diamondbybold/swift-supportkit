import SwiftUI

public struct APIImage<Placeholder: View>: View {
    private let url: URL?
    private let scaledToFill: Bool
    private let placeholder: () -> Placeholder
    
    public init(_ url: URL?,
                scaledToFill: Bool = false,
                placeholder: @escaping () -> Placeholder = { EmptyView() }) {
        self.url = url
        self.scaledToFill = scaledToFill
        self.placeholder = placeholder
    }
    
    public var body: some View {
        AsyncImage(url: url) { image in
            if scaledToFill {
                Color.clear.overlay {
                    image
                        .resizable()
                        .scaledToFill()
                }
            } else {
                image
                    .resizable()
                    .scaledToFit()
            }
        } placeholder: { 
            placeholder()
        }
    }
}
