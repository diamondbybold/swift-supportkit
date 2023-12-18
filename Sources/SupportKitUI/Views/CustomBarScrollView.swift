import SwiftUI

public struct CustomBarScrollView<Content: View>: View {
    @Binding private var topBarOpacity: Double
    @Binding private var bottomBarOpacity: Double
    private let content: () -> Content
    
    @Namespace private var container
    
    @State private var containerSize: CGFloat = .zero
    @State private var contentSize: CGFloat = .zero
    
    public init(topBarOpacity: Binding<Double>,
                bottomBarOpacity: Binding<Double>,
                @ViewBuilder content: @escaping () -> Content) {
        self._topBarOpacity = topBarOpacity
        self._bottomBarOpacity = bottomBarOpacity
        self.content = content
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollContentTopOffsetKey.self, value: proxy.frame(in: .named(container)).origin.y)
                }
                .frame(height: 0)
                .onPreferenceChange(ScrollContentTopOffsetKey.self) { topBarOpacity = calcOpacity($0) }
                
                content()
                
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollContentBottomOffsetKey.self, value: proxy.frame(in: .named(container)).origin.y)
                }
                .frame(height: 0)
                .onPreferenceChange(ScrollContentBottomOffsetKey.self) { value in
                    contentSize = value
                    bottomBarOpacity = calcOpacity(containerSize - contentSize)
                }
            }
        }
        .coordinateSpace(name: container)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(key: ScrollContainerSizeKey.self, value: proxy.frame(in: .local).size.height)
            }
            .onPreferenceChange(ScrollContainerSizeKey.self) { value in
                containerSize = value
                bottomBarOpacity = calcOpacity(containerSize - contentSize)
            }
        }
        .toolbarBackground(.hidden, for: .tabBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .bottomBar)
    }
    
    func calcOpacity(_ value: CGFloat) -> Double { max(0.0, min(1.0, value / -10.0)) }
}

public struct CustomTopBarScrollView<Content: View>: View {
    @Binding private var topBarOpacity: Double
    private let content: () -> Content
    
    @Namespace private var container
    
    public init(topBarOpacity: Binding<Double>,
                @ViewBuilder content: @escaping () -> Content) {
        self._topBarOpacity = topBarOpacity
        self.content = content
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ScrollContentTopOffsetKey.self, value: proxy.frame(in: .named(container)).origin.y)
                }
                .frame(height: 0)
                .onPreferenceChange(ScrollContentTopOffsetKey.self) { topBarOpacity = calcOpacity($0) }
                
                content()
            }
        }
        .coordinateSpace(name: container)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .bottomBar)
    }
    
    func calcOpacity(_ value: CGFloat) -> Double { max(0.0, min(1.0, value / -10.0)) }
}

public struct CustomBottomBarScrollView<Content: View>: View {
    @Binding private var bottomBarOpacity: Double
    private let content: () -> Content
    
    @Namespace private var container
    
    @State private var containerSize: CGFloat = .zero
    @State private var contentSize: CGFloat = .zero
    
    public init(bottomBarOpacity: Binding<Double>,
                @ViewBuilder content: @escaping () -> Content) {
        self._bottomBarOpacity = bottomBarOpacity
        self.content = content
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                content()
                
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollContentBottomOffsetKey.self, value: proxy.frame(in: .named(container)).origin.y)
                }
                .frame(height: 0)
                .onPreferenceChange(ScrollContentBottomOffsetKey.self) { value in
                    contentSize = value
                    bottomBarOpacity = calcOpacity(containerSize - contentSize)
                }
            }
        }
        .coordinateSpace(name: container)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(key: ScrollContainerSizeKey.self, value: proxy.frame(in: .local).size.height)
            }
            .onPreferenceChange(ScrollContainerSizeKey.self) { value in
                containerSize = value
                bottomBarOpacity = calcOpacity(containerSize - contentSize)
            }
        }
        .toolbarBackground(.hidden, for: .tabBar)
        .toolbarBackground(.hidden, for: .bottomBar)
    }
    
    func calcOpacity(_ value: CGFloat) -> Double { max(0.0, min(1.0, value / -10.0)) }
}

struct ScrollContainerSizeKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollContentTopOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollContentBottomOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
