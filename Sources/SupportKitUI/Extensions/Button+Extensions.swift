import SwiftUI

extension Button {
    public init(image: String, action: @escaping () -> Void) where Label == Image {
        self.init(action: action, label: { Image(image) })
    }
    
    public init(systemImage: String, action: @escaping () -> Void) where Label == Image {
        self.init(action: action, label: { Image(systemName: systemImage) })
    }
}
