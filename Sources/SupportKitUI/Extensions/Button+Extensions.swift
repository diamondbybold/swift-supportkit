import SwiftUI

extension Button {
    public init(asyncAction: @escaping () async -> Void, @ViewBuilder label: () -> Label) {
        self.init(action: { Task { await asyncAction() } }, label: label)
    }
    
    public init(_ titleKey: LocalizedStringKey, asyncAction: @escaping () async -> Void) where Label == Text {
        self.init(titleKey, action: { Task { await asyncAction() } })
    }
    
    public init(_ titleKey: LocalizedStringKey, role: ButtonRole, asyncAction: @escaping () async -> Void) where Label == Text {
        self.init(titleKey, role: role,  action: { Task { await asyncAction() } })
    }
    
    public init(_ role: ButtonRole, asyncAction: @escaping () async -> Void, @ViewBuilder label: () -> Label) {
        self.init(role: role, action: { Task { await asyncAction() } }, label: label)
    }
    
    public init(image: String, action: @escaping () -> Void) where Label == Image {
        self.init(action: action, label: { Image(image) })
    }
    
    public init(image: String, asyncAction: @escaping () async -> Void) where Label == Image {
        self.init(action: { Task { await asyncAction() } }, label: { Image(image) })
    }
    
    public init(systemImage: String, action: @escaping () -> Void) where Label == Image {
        self.init(action: action, label: { Image(systemName: systemImage) })
    }
    
    public init(systemImage: String, asyncAction: @escaping () async -> Void) where Label == Image {
        self.init(action: { Task { await asyncAction() } }, label: { Image(systemName: systemImage) })
    }
}
