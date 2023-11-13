import SwiftUI

struct NavigationContainer<Root: View>: View {
    @StateObject private var navigationContext = NavigationContext()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissConfirmation) private var dismissConfirmation
    @State private var showConfirmation: Bool = false
    
    @ViewBuilder
    let root: () -> Root
    
    var body: some View {
        NavigationStack(path: $navigationContext.path) {
            root()
                .navigationDestination(for: NavigationContext.DestinationData.self) { data in
                    AnyView(data.content())
                }
        }
        .environmentObject(navigationContext)
        .sheet(item: $navigationContext.sheet) { item in
            AnyView(item.content())
        }
        .fullScreenCover(item: $navigationContext.fullScreenCover) { item in
            AnyView(item.content())
        }
        .confirmationDialog(navigationContext.confirmation?.title ?? "",
                            isPresented: .present(value: $navigationContext.confirmation),
                            titleVisibility: .visible) {
            if let confirmation = navigationContext.confirmation {
                Button(confirmation.actionLabel, role: confirmation.actionRole) {
                    confirmation.action()
                }
            }
        } message: {
            if let message = navigationContext.confirmation?.message {
                Text(message)
            }
        }
        .confirmationDialog(dismissConfirmation.title,
                            isPresented: $showConfirmation,
                            titleVisibility: .visible) {
            Button(dismissConfirmation.actionLabel, role: dismissConfirmation.actionRole) {
                dismissConfirmation.action()
                dismiss()
            }
        } message: {
            if let message = dismissConfirmation.message {
                Text(message)
            }
        }
        .onAppear {
            navigationContext.onDismiss = { withConfirmation in
                if withConfirmation {
                    showConfirmation = true
                } else {
                    dismiss()
                }
            }
        }
    }
}

extension View {
    public func navigationContainer() -> some View {
        NavigationContainer { self }
    }
    
    public func navigationContainer(dismissConfirmation: ActionConfirmation) -> some View {
        NavigationContainer { self }
            .environment(\.dismissConfirmation, dismissConfirmation)
    }
    
    public func navigationContainer<T: ObservableObject>(_ contextObject: T) -> some View {
        NavigationContainer { self }
            .environmentObject(contextObject)
    }
    
    public func navigationContainer<T: ObservableObject>(_ contextObject: T,
                                                         dismissConfirmation: ActionConfirmation) -> some View {
        NavigationContainer { self }
            .environmentObject(contextObject)
            .environment(\.dismissConfirmation, dismissConfirmation)
    }
    
    public func navigationContainer(title: LocalizedStringKey,
                                    image: String) -> some View {
        NavigationContainer { self }
            .tabItem { Label(title, image: image) }
    }
    
    public func navigationContainer<T: ObservableObject>(_ contextObject: T,
                                                         title: LocalizedStringKey,
                                                         image: String) -> some View {
        NavigationContainer { self }
            .tabItem { Label(title, image: image) }
            .environmentObject(contextObject)
    }
    
    public func navigationContainer(title: LocalizedStringKey,
                                    symbol: String) -> some View {
        NavigationContainer { self }
            .tabItem { Label(title, systemImage: symbol) }
    }
    
    public func navigationContainer<T: ObservableObject>(_ contextObject: T,
                                                         title: LocalizedStringKey,
                                                         symbol: String) -> some View {
        NavigationContainer { self }
            .tabItem { Label(title, systemImage: symbol) }
            .environmentObject(contextObject)
    }
}

// MARK: - Environment Values
struct DismissConfirmationKey: EnvironmentKey {
    static let defaultValue: ActionConfirmation = ActionConfirmation(title: "Are you sure?",
                                                                     actionLabel: "Yes")
}

extension EnvironmentValues {
    var dismissConfirmation: ActionConfirmation {
        get { self[DismissConfirmationKey.self] }
        set { self[DismissConfirmationKey.self] = newValue }
    }
}
