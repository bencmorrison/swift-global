# Global

There have been just a small few instances where I'd like to be able to use `SwiftUI`'s `@Environment` in non-`SwiftUI`
areas of some applications that are a mix of `SwiftUI` and `UIKit`. Why? I guess because I find the idea better than
using a singleton.

So I created `Global` which behaves like `@Environment`. It even has a similar setup as `@Environment`.

## Usage

``swift
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

// Then you use the property wrapper in some type.
final class SomeRandomClass {
    @Global(\.state) var state
}
```

## Notes

- I will add testing... at some point.
