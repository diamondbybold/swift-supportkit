import Foundation

extension Array where Element: Equatable {
    public func after(element: Element) -> Element? {
        guard let index = firstIndex(of: element), index + 1 < count else { return nil }
        return self[index + 1]
    }
    
    public func before(element: Element) -> Element? {
        guard let index = firstIndex(of: element), index > 0 else { return nil }
        return self[index - 1]
    }
}

extension Array where Element: Identifiable {
    public func contains(element: Element) -> Bool { contains { $0.id == element.id } }
    
    public func index(of element: Element) -> Int? { firstIndex { $0.id == element.id } }
    
    @discardableResult
    public mutating func replace(_ element: Element, with newElement: Element) -> Bool {
        if let index = firstIndex(where: { $0.id == element.id }) {
            self[index] = newElement
            return true
        }
        return false
    }
    
    @discardableResult
    public mutating func remove(_ element: Element) -> Bool {
        if let index = firstIndex(where: { $0.id == element.id }) {
            self.remove(at: index)
            return true
        }
        return false
    }
}

extension Array {
    public func split() -> ([Element], [Element]) {
        let half = count / 2 + count % 2
        let head = self[0..<half]
        let tail = self[half..<count]

        return (Array(head), Array(tail))
    }
}
