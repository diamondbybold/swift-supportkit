import UIKit

extension UIApplication {
    public var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
    
    public var safeAreaInsets: UIEdgeInsets { currentKeyWindow?.safeAreaInsets ?? .zero }
    
    public var rootViewController: UIViewController? { currentKeyWindow?.rootViewController }
    
    public var topViewController: UIViewController? {
        var vc = rootViewController
        while let pvc = vc?.presentedViewController { vc = pvc }
        return vc
    }
    
    public func changeToOrientation(_ orientation: UIInterfaceOrientationMask) {
        let windowScene = connectedScenes.first as? UIWindowScene
        windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
        rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}
