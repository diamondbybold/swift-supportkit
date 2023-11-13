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
        .confirmationDialog(dismissConfirmation.title,
                            isPresented: $showConfirmation) {
            Button(dismissConfirmation.actionLabel, role: .destructive) {
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
    
    public func navigationContainer(dismissConfirmation: DismissConfirmation) -> some View {
        NavigationContainer { self }
            .environment(\.dismissConfirmation, dismissConfirmation)
    }
    
    public func navigationContainer<T: ObservableObject>(_ contextObject: T) -> some View {
        NavigationContainer { self }
            .environmentObject(contextObject)
    }
    
    public func navigationContainer<T: ObservableObject>(_ contextObject: T,
                                                         dismissConfirmation: DismissConfirmation) -> some View {
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
public struct DismissConfirmation {
    let title: LocalizedStringKey
    var message: LocalizedStringKey? = nil
    let actionLabel: LocalizedStringKey
    var action: () -> Void = { }
}

struct DismissConfirmationKey: EnvironmentKey {
    static let defaultValue: DismissConfirmation = DismissConfirmation(title: "Are you sure?",
                                                                       actionLabel: "Yes")
}

extension EnvironmentValues {
    var dismissConfirmation: DismissConfirmation {
        get { self[DismissConfirmationKey.self] } 
        set { self[DismissConfirmationKey.self] = newValue }
    }
}
