import Foundation

extension Array where Element: Equatable {
    public var unique: [Element] { reduce([]) { $0.contains($1) ? $0 : $0 + [$1] } }
    
    public func after(element: Element) -> Element? {
        guard let index = firstIndex(of: element), index + 1 < count else { return nil }
        return self[index + 1]
    }
    
    public func before(element: Element) -> Element? {
        guard let index = firstIndex(of: element), index > 0 else { return nil }
        return self[index - 1]
    }
}

extension Array where Element == Date {
    public var uniqueDate: [Element] { reduce([]) { $0.map { $0.isoDateString }.contains($1.isoDateString) ? $0 : $0 + [$1] } }
    public var uniqueYear: [Element] { reduce([]) { $0.map { $0.isoYearString }.contains($1.isoYearString) ? $0 : $0 + [$1] } }
    public var uniqueYearMonth: [Element] { reduce([]) { $0.map { $0.isoYearMonthString }.contains($1.isoYearMonthString) ? $0 : $0 + [$1] } }
}

extension Array where Element: Identifiable {
    public var uniqueElements: [Element] { reduce([]) { $0.contains(element: $1) ? $0 : $0 + [$1] } }
    
    public func contains(element: Element) -> Bool { contains { $0.id == element.id } }
    
    public func index(of element: Element) -> Int? { firstIndex { $0.id == element.id } }
    
    public mutating func update(_ element: Element) {
        if let index = firstIndex(where: { $0.id == element.id }) {
            self[index] = element
        }
    }
    
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
