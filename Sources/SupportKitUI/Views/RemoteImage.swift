import SwiftUI

public struct RemoteImage<Placeholder: View>: View {
    private let url: URL?
    private let scaledToFill: Bool
    private let transition: Bool
    private let placeholder: () -> Placeholder
    
    public init(_ url: URL?,
                scaledToFill: Bool = false,
                transition: Bool = true,
                placeholder: @escaping () -> Placeholder = { EmptyView() }) {
        self.url = url
        self.scaledToFill = scaledToFill
        self.transition = transition
        self.placeholder = placeholder
    }
    
    public var body: some View {
        if transition {
            AsyncImage(url: url,
                       transaction: Transaction(animation: .default)) { phase in
                if let image = phase.image {
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
                } else {
                    placeholder()
                }
            }
        } else {
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
}
