import Foundation

public protocol Updatable { }

extension Updatable {
    private static var notification: Notification.Name { .init("Update\(Self.self)Notification") }
    
    public static var updates: NotificationCenter.Notifications {
        NotificationCenter.default.notifications(named: Self.notification)
    }
    
    public static func update(_ object: Self) {
        NotificationCenter.default.post(name: Self.notification, object: object)
    }
}

public protocol Deletable {
    var isDeleted: Bool { get set }
}

extension Array where Element: Identifiable {
    public mutating func update(_ element: Element) {
        if let index = firstIndex(where: { $0.id == element.id }) {
            if let deletableElement = element as? Deletable,
               deletableElement.isDeleted {
                self.remove(at: index)
            } else {
                self[index] = element
            }
        } else {
            self.append(element)
        }
    }
}
