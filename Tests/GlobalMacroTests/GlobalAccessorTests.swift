// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(GlobalMacroMacros)
import GlobalMacroMacros
#endif

final class GlobalAccessorTests: XCTestCase {
    let testMacros: [String: Macro.Type] = {
        #if canImport(GlobalMacroMacros)
        [
            "GlobalAccessor": GlobalAccessorMacro.self,
        ]
        #else
        []
        #endif
    }()
    
    func testMacro() throws {
        #if canImport(GlobalMacroMacros)
        assertMacroExpansion(
            """
            extension SomeExtension {
                @GlobalAccessor(\\.state) var state: GlobalState
            }
            """,
            expandedSource: """
            extension SomeExtension {
                var state: GlobalState {
                    get {
                        GlobalValues.get(\\.state)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroExplicitGetter() throws {
        #if canImport(GlobalMacroMacros)
        assertMacroExpansion(
            """
            extension SomeExtension {
                @GlobalAccessor(\\.state, type: .getter) var state: GlobalState
            }
            """,
            expandedSource: """
            extension SomeExtension {
                var state: GlobalState {
                    get {
                        GlobalValues.get(\\.state)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroWithSetter() throws {
        #if canImport(GlobalMacroMacros)
        assertMacroExpansion(
            """
            extension SomeExtension {
                @GlobalAccessor(\\.state, type: .getterAndSetter) var state: GlobalState
            }
            """,
            expandedSource: """
            extension SomeExtension {
                var state: GlobalState {
                    get {
                        GlobalValues.get(\\.state)
                    }
                    set {
                        GlobalValues.set(\\.state, to: newValue)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroIgnoresAssignedValue() throws {
        #if canImport(GlobalMacroMacros)
        assertMacroExpansion(
            """
            extension SomeExtension {
                @GlobalAccessor(\\.state) var state: GlobalState = .unknown
            }
            """,
            expandedSource: """
            extension SomeExtension {
                var state: GlobalState {
                    get {
                        GlobalValues.get(\\.state)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroFailsWhenNotInExtension() throws {
        #if canImport(GlobalMacroMacros)
        assertMacroExpansion(
            """
            struct Thing {
                @GlobalAccessor(\\.state) var state: GlobalState
            }
            """,
            expandedSource: """
            struct Thing {
                var state: GlobalState
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    from: .requiresUseInExtension(forMacro: GlobalAccessorMacro.self),
                    line: 2, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
