import Foundation

public protocol Invalidatable { }

extension Invalidatable {
    public static var notification: Notification.Name { .init("Invalidate\(Self.self)Notification") }
    
    public static var invalidates: NotificationCenter.Notifications {
        NotificationCenter.default.notifications(named: Self.notification)
    }
    
    public static func invalidate() {
        NotificationCenter.default.post(name: Self.notification, object: nil)
    }
}
