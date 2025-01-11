// Copyright © 2025 Ben Morrison. All rights reserved.

/// Conformance to this protocol allows your object to be used as a `Global` value.
/// You set this up exactly like how you would use `EnvironmentKey` in `SwiftUI`
public protocol GlobalKey {
    /// The associated type that represents the type of the global key's value.
    associatedtype Value
    /// The default value that should be set for the `Global`
    /// This can be nullable, which allows you have this not always set.
    static var defaultValue: Value { get }
}
