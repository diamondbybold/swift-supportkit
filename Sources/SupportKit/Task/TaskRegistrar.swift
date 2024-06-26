import Foundation
import Combine

public class TaskRegistrar {
    public static var shared = TaskRegistrar()
    
    private var tasks: [String: Task<Void, Never>] = [:]
    private var objTasks: [ObjectIdentifier: [String: Task<Void, Never>]] = [:]
    
    deinit { cancelAll() }
    
    public func cancelWithId(_ id: String) {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
    }
    
    public func cancelWithObject(_ object: AnyObject, id: String? = nil) {
        let objId = ObjectIdentifier(object)
        
        if let id {
            objTasks[objId]?[id]?.cancel()
            if objTasks[objId]?.isEmpty ?? false { objTasks.removeValue(forKey: objId) }
        } else {
            objTasks[objId]?.values.forEach { $0.cancel() }
            objTasks.removeValue(forKey: objId)
        }
    }
    
    public func cancelAll() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
        
        objTasks.values.forEach { o in o.values.forEach { t in t.cancel() } }
        objTasks.removeAll()
    }
    
    public func callAsFunction(id: String = UUID().uuidString,
                               task: @escaping () async -> Void) {
        tasks[id] = Task { await task() }
    }
    
    public func callAsFunction(object: AnyObject,
                               id: String = UUID().uuidString,
                               task: @escaping () async -> Void) {
        let objId = ObjectIdentifier(object)
        
        if objTasks[objId] == nil {
            objTasks[objId] = [id: Task { await task() }]
        } else {
            objTasks[objId]?[id] = Task { await task() }
        }
    }
}
