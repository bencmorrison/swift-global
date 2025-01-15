// Copyright © 2025 Ben Morrison. All rights reserved.

import Foundation

/// The `Global` framework uses `GlobalValues` to expose a collection of singleton
/// like values to your application. Use the `Global` property wrapper and specify
/// the value's key path. Ensure your value conforms to `GlobalKey`.
public final class GlobalValues: @unchecked Sendable {
    // MARK: - Static
    nonisolated(unsafe)
    static var shared: GlobalValues = .init()
    
    /// Allows you to directly get a value at a specified KeyPath.
    /// - Parameter keyPath: The KeyPath of the value you want to get.
    /// - Returns: The value stored in the `GlobalValues`
    public static func get<Value>(_ keyPath: WritableKeyPath<GlobalValues, Value>) -> Value {
        shared[keyPath: keyPath]
    }
    
    /// Allows you to directly set a value at a specified KeyPath.
    /// - Parameters:
    ///   - keyPath: The KeyPath of the value you wish to set.
    ///   - newValue: The value you wish to set to in `GlobalValues`
    public static func set<Value>(_ keyPath: WritableKeyPath<GlobalValues, Value>, to newValue: Value) {
        shared[keyPath: keyPath] = newValue
    }
    // MARK: - Instance
    
    fileprivate var lock: NSRecursiveLock
    fileprivate var storage: [ObjectIdentifier: Any]
    
    fileprivate init() {
        storage = [:]
        lock = .init()
    }
    
    public subscript<K: GlobalKey>(_ key: K.Type) -> K.Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return storage[ObjectIdentifier(key)] as? K.Value ?? K.defaultValue
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}

#if DEBUG
extension GlobalValues: CustomDebugStringConvertible {
    public var debugDescription: String {
        var desc = "GlobalValues: { \n"
        storage.forEach {
            desc += "\t[\($0): \($1)],\n"
        }
        desc += "}"
        return desc
    }
    
    func wipeStorage() {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll()
    }
    
    static func setSharedStorage(_ storage: GlobalValues) {
        shared = storage
    }
    
    static func testStorage() -> GlobalValues { .init() }
}
#endif
