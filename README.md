# Global

There have been just a small few instances where I'd like to be able to use `SwiftUI`'s `@Environment` in non-`SwiftUI`
areas of some applications that are a mix of `SwiftUI` and `UIKit`. Why? I guess because I find the idea better than
using a singleton.

So I created `Global` which behaves like `@Environment`. It even has a similar setup as `@Environment`.

## Usage

There are two ways you can use `Global`. The first way is the non-macro way. This way gives you full control over everything when it comes to using `Global`. The second way is via the macro, `@GlobalValue`, that will mostly automate the boilerplate code needed in the non-macro way of doing things.

### The non-macro way

This example shows you how to enable a type, in this case an Enum, to be used as a `Global`. This is the typical way one would set it up, as if they were using `@Environment` from `SwiftUI`. It is a bit wordy but not too wordy.

#### SomeGlobalState.swift
```swift
import Global

// This is the enum we want at a global scope
enum SomeGlobalState {
    case unknown, loading, loaded(Data)
}

// We are going to extend out enum by conforming to `GlobalKey`
extension SomeGlobalState: GlobalKey {
    static let defaultValue: Self = .unknown
}

// Then we extend `GlobalValues` to give us a key path to use.
extension GlobalValues {
    // This is the key path we are going to use.
    // We will need to create the setter and getter for the value.
    var state: SomeGlobalState {
        get { self[SomeGlobalState.self] }
        set { self[SomeGlobalState.self] = newValue }
    }
}
```

#### Example Usage

```swift
import Global

// Then you use the property wrapper in some type.
final class SomeRandomClass {
    /// This will allow us access to the `SomeGlobalState` stored in `GlobalValues`
    @Global(\.state) var state
}
```

### The macro way.

The macro way is pretty simple, and easy. We will use the type above to show this example as well. It too takes the same idea as the `@Enviornment` maco, and also takes on `@Entry` macro as well. To prevent any sort of headaches I decided to not name my macro `@Entry` as well. Instead we will use `GlobalValue`.

Bu default the macro will create all defaultValues as a stored constant property (`let v: Int = 0`). If you would like to change this to a computed variable add the argument `propertyType` to your macro. Example: `@GlobalValue(propertyType: .computed) var v: Int = 0` which will result in `var v: Int { 0 }`

**Requirments** to keep in mind:

- You must use the macro in an extension of `GlobalValues`
- At this type your variables are required to have type annotation.
- The variable must be initalized _unless_ it is optional.

#### SomeGlobalState.swift

```swift
// This is the enum we want at a global scope
enum SomeGlobalState {
    case unknown, loading, loaded(Data)
}
```

#### GlobalValues.swift
```swift
import Global
import GlobalMacro

extension GlobalValues {
    // The macro will automatically create all needed code to allow you to use the
    // @Global property wrapper.
    @GlobalValue var state: SomeGlobalState = .unknown
    // You can add all types you want global in this sigle file.
    // Another Example:
    @GlobalValue var state: String = "Another Value"
}
```

#### Example Usage

```swift
import Global

// Then you use the property wrapper in some type.
final class SomeRandomClass {
    /// This will allow us access to the `SomeGlobalState` stored in `GlobalValues`
    @Global(\.state) var state
}
```

## Adding `Global` as a depenancy

To use the `Global` library in a SwiftPM project, add the following line to the dependencies in your Package.swift file:

```swift
.package(url: "https://github.com/bencmorrison/swift-global.git", from: "0.2.0"),
```

include `Global` and `GlobalMacro` (only if you plan to use the macro way) as dependancies for your executable targets

```swift
.target(name: "<target>", dependencies: [
    .product(name: "Global", package: "swift-global"),
    .product(name: "GlobalMacro", package: "swift-global"),
]),
```

Finally, add `import Global` and `import GlobalMacro` to your source code as needed.

## Notes

- There is some testing around the macro and global in general. I hope to more in the future.
