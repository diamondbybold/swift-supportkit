import SwiftUI

struct TaskFirstTimeViewModifier: ViewModifier {
    let perform: () async -> Void
    
    @State private var performed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .task {
                if !performed {
                    await perform()
                    performed = true
                }
            }
    }
}

extension View {
    public func taskFirstTime(_ perform: @escaping () async -> Void) -> some View {
        self.modifier(TaskFirstTimeViewModifier(perform: perform))
    }
}
