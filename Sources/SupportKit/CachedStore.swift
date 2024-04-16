import Foundation

public class CachedStore<T: Identifiable>: Store<T> {
    public var cachedElements: [String: [T]] = [:]
    public var shouldAlwaysUpdate: Bool = false
    
    public func fetch(forKey key: String, _ fetchRequest: FetchRequest, refreshing: Bool? = nil) async {
        let cache = cachedElements[key]
        elements = cache ?? []
        
        if cache == nil || shouldAlwaysUpdate {
            await fetch(fetchRequest, refreshing: refreshing)
            cachedElements[key] = elements
        }
    }
    
    public func fetch(forKey key: String, refreshing: Bool? = nil, _ task: @escaping (Int) async throws -> ([T], Int?)) async {
        let cache = cachedElements[key]
        elements = cache ?? []
        
        if cache == nil || shouldAlwaysUpdate {
            await fetch(refreshing: refreshing, task)
            cachedElements[key] = elements
        }
    }
    
    public func fetch(forKey key: String, refreshing: Bool? = nil, _ task: @escaping () async throws -> [T]) async {
        let cache = cachedElements[key]
        elements = cache ?? []
        
        if cache == nil || shouldAlwaysUpdate {
            await fetch(refreshing: refreshing, task)
            cachedElements[key] = elements
        }
    }
    
    public func fetch(forKey key: String, refreshing: Bool? = nil, _ task: @escaping () async throws -> T?) async {
        let cache = cachedElements[key]
        elements = cache ?? []
        
        if cache == nil || shouldAlwaysUpdate {
            await fetch(refreshing: refreshing, task)
            cachedElements[key] = elements
        }
    }
    
    public func fetch(forKey key: String, refreshing: Bool? = nil) async {
        let cache = cachedElements[key]
        elements = cache ?? []
        
        if cache == nil || shouldAlwaysUpdate {
            await fetch(refreshing: refreshing)
            cachedElements[key] = elements
        }
    }
}
