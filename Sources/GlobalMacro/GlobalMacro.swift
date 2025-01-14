// Copyright © 2025 Ben Morrison. All rights reserved.

/// The macro `GlobalValue` can be used to make any a `GlobalKey` without adding conformance
/// to the protocol directly to the type. It will also create the code needed in `GlobalValues` to
/// allow use of the value via the `@Global(_)` property wrapper.
///
/// To use this you will need to still create an extension to `GlobalValues` and then add the values
/// via the macro.
///
/// ```swift
/// extension GlobalValues {
///     @Entry var state: String = "Some string for global use."
/// }
/// ```
///
/// - Parameter evaluation: The type of value you want the default property to be. Default: `.constant`
///
@attached(accessor)
@attached(peer, names: prefixed(__GlobalKey_))
public macro GlobalValue(propertyType: PropertyType = .constant) = #externalMacro(module: "GlobalMacroMacros", type: "GlobalValueMacro")
