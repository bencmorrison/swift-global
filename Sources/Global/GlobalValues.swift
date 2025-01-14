// Copyright © 2025 Ben Morrison. All rights reserved.

import Foundation

/// The `Global` framework uses `GlobalValues` to expose a collection of singleton
/// like values to your application. Use the `Global` property wrapper and specify
/// the value's key path. Ensure your value conforms to `GlobalKey`.
public final class GlobalValues: @unchecked Sendable {
    nonisolated(unsafe)
    static var shared: GlobalValues = .init()
    
    fileprivate var lock: pthread_rwlock_t
    fileprivate var storage: [ObjectIdentifier: Any]
    
    fileprivate init() {
        storage = [:]
        lock = pthread_rwlock_t()
        pthread_rwlock_init(&lock, nil)
    }
    
    deinit { pthread_rwlock_destroy(&lock) }
    
    public subscript<K: GlobalKey>(_ key: K.Type) -> K.Value {
        get {
            pthread_rwlock_rdlock(&lock)
            defer { pthread_rwlock_unlock(&lock) }
            return storage[ObjectIdentifier(key)] as? K.Value ?? K.defaultValue
        }
        set {
            pthread_rwlock_wrlock(&lock)
            defer { pthread_rwlock_unlock(&lock) }
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
        pthread_rwlock_rdlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        storage.removeAll()
    }
    
    static func setSharedStorage(_ storage: GlobalValues) {
        shared = storage
    }
    
    static func testStorage() -> GlobalValues { .init() }
}
#endif
