// Copyright © 2025 Ben Morrison. All rights reserved.

/// Defines the list of options of the type of property that the default value will be for the accessors.
public enum PropertyType: CaseIterable {
    /// Use a stored constant property for the default value. This is the default behaviour.
    ///
    /// Example: `static let aString = "A String."`
    case constant
    /// Use a computed property for the default value.
    ///
    /// Example: `static var aString { "A String" }`
    case computed
}
