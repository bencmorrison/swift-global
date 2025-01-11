// Copyright © 2025 Ben Morrison. All rights reserved.

/// You can think of this as a port of the `SwiftUI`'s `@Environment` property wrapper.
/// Basically if you app has Singletons and you want a cleaner way to use them
/// this can be an easier way to use them. Plus it looks neat!
@propertyWrapper
public struct Global<Value> {
    private let keyPath: WritableKeyPath<GlobalValues, Value>
    
    /// The current value of the Global object.
    public var wrappedValue: Value {
        get { GlobalValues.shared[keyPath: keyPath] }
        set { GlobalValues.shared[keyPath: keyPath] = newValue }
    }
    
    /// Creates a Global property to read the specific key path.
    /// - Parameter keyPath: The key path to use.
    public init(_ keyPath: WritableKeyPath<GlobalValues, Value>) {
        self.keyPath = keyPath
    }
}
