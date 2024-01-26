import Foundation

public protocol Previewable {
    static var previews: [Self] { get }
}

extension Previewable {
    public static var previews: [Self] { [] }
}
