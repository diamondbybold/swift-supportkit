import SwiftUI

public class InterfaceOrientationAppDelegate: NSObject, UIApplicationDelegate {
    public static var interfaceOrientation: UIInterfaceOrientationMask = .portrait {
        didSet {
            UIApplication.shared.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    
    public func application(_ application: UIApplication,
                            supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        InterfaceOrientationAppDelegate.interfaceOrientation
    }
}

struct InterfaceOrientationViewModifier: ViewModifier {
    let interfaceOrientation: UIInterfaceOrientationMask
    @State private var savedInterfaceOrientation: UIInterfaceOrientationMask = .portrait
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                savedInterfaceOrientation = InterfaceOrientationAppDelegate.interfaceOrientation
                InterfaceOrientationAppDelegate.interfaceOrientation = interfaceOrientation
            }
            .onDisappear {
                InterfaceOrientationAppDelegate.interfaceOrientation = savedInterfaceOrientation
            }
    }
}

extension View {
    public func interfaceOrientation(_ interfaceOrientation: UIInterfaceOrientationMask) -> some View {
        self.modifier(InterfaceOrientationViewModifier(interfaceOrientation: interfaceOrientation))
    }
}
