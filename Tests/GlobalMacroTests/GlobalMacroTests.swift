// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(GlobalMacroMacros)
import GlobalMacroMacros

let testMacros: [String: Macro.Type] = [
    "GlobalValue": GlobalValueMacro.self,
]
#endif

final class GlobalMacroTests: XCTestCase {
    func testMacroWithValue() throws {
        #if canImport(GlobalMacroMacros)
        assertMacroExpansion(
            """
            extension GlobalValues {
                @GlobalValue var state: GlobalState = .whoKnows
            }
            """,
            expandedSource: """
            extension GlobalValues {
                var state: GlobalState {
                    get {
                        self[__GlobalKey_state.self]
                    }
                    set {
                        self[__GlobalKey_state.self] = newValue
                    }
                }
            
                private struct __GlobalKey_state: GlobalKey {
                    typealias Value = GlobalState
                    static var defaultValue: Value {
                        .whoKnows
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
    
    func testMacroWithNil() throws {
        #if canImport(GlobalMacroMacros)
        assertMacroExpansion(
            """
            extension GlobalValues {
                @GlobalValue var state: GlobalState? = nil
            }
            """,
            expandedSource: """
            extension GlobalValues {
                var state: GlobalState? {
                    get {
                        self[__GlobalKey_state.self]
                    }
                    set {
                        self[__GlobalKey_state.self] = newValue
                    }
                }
            
                private struct __GlobalKey_state: GlobalKey {
                    typealias Value = GlobalState?
                    static var defaultValue: Value {
                        nil
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
    
    func testMacroWithNilNotSet() throws {
        #if canImport(GlobalMacroMacros)
        assertMacroExpansion(
            """
            extension GlobalValues {
                @GlobalValue var state: GlobalState?
            }
            """,
            expandedSource: """
            extension GlobalValues {
                var state: GlobalState? {
                    get {
                        self[__GlobalKey_state.self]
                    }
                    set {
                        self[__GlobalKey_state.self] = newValue
                    }
                }
            
                private struct __GlobalKey_state: GlobalKey {
                    typealias Value = GlobalState?
                    static var defaultValue: Value {
                        nil
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
    
    func testMacroWithOptionalValue() throws {
        #if canImport(GlobalMacroMacros)
        assertMacroExpansion(
            """
            extension GlobalValues {
                @GlobalValue var state: GlobalState? = .whoKnows
            }
            """,
            expandedSource: """
            extension GlobalValues {
                var state: GlobalState? {
                    get {
                        self[__GlobalKey_state.self]
                    }
                    set {
                        self[__GlobalKey_state.self] = newValue
                    }
                }
            
                private struct __GlobalKey_state: GlobalKey {
                    typealias Value = GlobalState?
                    static var defaultValue: Value {
                        .whoKnows
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
}
