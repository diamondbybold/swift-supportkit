import SwiftUI

public struct NavigationButton<Label, Route>: View where Label: View, Route: NavigationRoute {
    private let label: Label
    private let mode: Mode
    private let route: Route
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    public init(_ titleKey: LocalizedStringKey, mode: Mode, route: Route) where Label == Text {
        self.label = Text(titleKey)
        self.mode = mode
        self.route = route
    }
    
    public init(mode: Mode, route: Route, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.mode = mode
        self.route = route
    }
    
    public init(image: String, mode: Mode, route: Route) where Label == Image {
        self.label = Image(image)
        self.mode = mode
        self.route = route
    }
    
    public init(symbol: String, mode: Mode, route: Route) where Label == Image {
        self.label = Image(systemName: symbol)
        self.mode = mode
        self.route = route
    }
    
    public var body: some View {
        Button {
            switch mode {
            case .destination:
                navigationContext.destination(route)
            case .sheet:
                navigationContext.sheet(route)
            case .fullScreenCover, .overlay:
                navigationContext.fullScreenCover(route)
            }
        } label: {
            label
        }
        .transaction { transaction in
            transaction.disablesAnimations = mode == .overlay
        }
    }
}

// Support Types
extension NavigationButton {
    public enum Mode {
        case destination
        case sheet
        case fullScreenCover
        case overlay
    }
}
