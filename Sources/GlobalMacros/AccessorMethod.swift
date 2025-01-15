// Copyright © 2025 Ben Morrison. All rights reserved.

/// Used by the `@GlobalAccessor` macro. When present it will
/// allow an extension to use the values stored in `GlobalValues`
public enum AccessorMethod {
    /// Create a getter only for the `@GlobalAccessor`
    /// This is the Default.
    case getter
    /// Create a getter and setter for the `@GlobalAccessor`
    case getterAndSetter
}
