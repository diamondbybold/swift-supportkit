import SwiftUI

struct NavigationContainer<Root: View>: View {
    @StateObject private var navigationContext = NavigationContext()
    
    @Environment(\.dismiss) private var dismiss
    
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
            if let actions = navigationContext.confirmation?.actions {
                AnyView(actions().environmentObject(navigationContext))
            }
        } message: {
            if let message = navigationContext.confirmation?.message {
                Text(message)
            }
        }
        .alert(navigationContext.alert?.title ?? "",
               isPresented: .present(value: $navigationContext.alert)) {
            if let actions = navigationContext.alert?.actions {
                AnyView(actions().environmentObject(navigationContext))
            }
        } message: {
            if let message = navigationContext.alert?.message {
                Text(message)
            }
        }
        .onChange(of: navigationContext.shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
        .onAppear {
            navigationContext.isActive = true
        }
        .onDisappear {
            navigationContext.isActive = false
        }
    }
}

struct CustomPathNavigationContainer<Root: View, T: Hashable>: View {
    @StateObject private var navigationContext = NavigationContext()
    
    @Environment(\.dismiss) private var dismiss
    
    let path: Binding<[T]>
    
    @ViewBuilder
    let root: () -> Root
    
    var body: some View {
        NavigationStack(path: path) {
            root()
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
            if let actions = navigationContext.confirmation?.actions {
                AnyView(actions().environmentObject(navigationContext))
            }
        } message: {
            if let message = navigationContext.confirmation?.message {
                Text(message)
            }
        }
        .alert(navigationContext.alert?.title ?? "",
               isPresented: .present(value: $navigationContext.alert)) {
            if let actions = navigationContext.alert?.actions {
                AnyView(actions().environmentObject(navigationContext))
            }
        } message: {
            if let message = navigationContext.alert?.message {
                Text(message)
            }
        }
        .onChange(of: navigationContext.shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

extension View {
    public func navigationContainer() -> some View {
        NavigationContainer { self }
    }
    
    public func navigationContainer<T: Hashable>(path: Binding<[T]>) -> some View {
        CustomPathNavigationContainer(path: path) { self }
    }
    
    public func navigationContainer(title: LocalizedStringKey,
                                    image: String) -> some View {
        NavigationContainer { self }
            .tabItem { Label(title, image: image) }
    }
    
    public func navigationContainer(title: LocalizedStringKey,
                                    systemImage: String) -> some View {
        NavigationContainer { self }
            .tabItem { Label(title, systemImage: systemImage) }
    }
}
