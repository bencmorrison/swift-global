// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftSyntax
import SwiftParser
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

import GlobalMacro

#if canImport(GlobalMacroMacros)
@testable import GlobalMacroMacros
#endif

final class GlobalMacroFailureTests: XCTestCase {
    let propertyTypes = PropertyType.allCases
    
    let testMacros: [String: Macro.Type] = {
        #if canImport(GlobalMacroMacros)
        [
            "GlobalValue": GlobalValueMacro.self,
        ]
        #else
        []
        #endif
    }()
    
    func testMacroRequiesVariableDeclaration() throws {
        #if canImport(GlobalMacroMacros)
        let invalidInput = """
        struct GlobalValues {
            @GlobalValue func someFunction() -> String { "" }
        }
        """
        
        let expectedOutput = """
        struct GlobalValues {
            func someFunction() -> String { "" }
        }
        """
        assertMacroExpansion(
            invalidInput,
            expandedSource: expectedOutput,
            diagnostics: [
                DiagnosticSpec(from: .requiresVariableDeclaration, line: 2, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroThrowsWhenOutsideGlobalValues() throws {
        #if canImport(GlobalMacroMacros)
        let invalidInput = """
        struct OtherType {
            @GlobalValue var state: String = "Some value"
        }
        """
        
        let expectedOutput = """
        struct OtherType {
            var state: String = "Some value"
        }
        """
        
        assertMacroExpansion(
            invalidInput,
            expandedSource: expectedOutput,
            diagnostics: [
                DiagnosticSpec(from: .requiresUseInGlobalValuesExtension, line: 2, column: 5),
                DiagnosticSpec(from: .requiresUseInGlobalValuesExtension, line: 2, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroThowsWhenTypeAnnotationRequired() throws {
    #if canImport(GlobalMacroMacros)
        let invalidInput = """
        extension GlobalValues {
            @GlobalValue var state = "Some String"
        }
        """
        
        let expectedOutput = """
        extension GlobalValues {
            var state {
                get {
                    self[__GlobalKey_state.self]
                }
                set {
                    self[__GlobalKey_state.self] = newValue
                }
            }
        }
        """
        
        assertMacroExpansion(
            invalidInput,
            expandedSource: expectedOutput,
            diagnostics: [
                DiagnosticSpec(from: .requiresTypeAnnotation, line: 2, column: 5)
            ],
            macros: testMacros
        )
    #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
    }
    
    func testMacroThowsWhenVariableInitalizationRequired() throws {
    #if canImport(GlobalMacroMacros)
        let invalidInput = """
        extension GlobalValues {
            @GlobalValue var state: String
        }
        """
        
        let expectedOutput = """
        extension GlobalValues {
            var state: String {
                get {
                    self[__GlobalKey_state.self]
                }
                set {
                    self[__GlobalKey_state.self] = newValue
                }
            }
        }
        """
        
        assertMacroExpansion(
            invalidInput,
            expandedSource: expectedOutput,
            diagnostics: [
                DiagnosticSpec(from: .requiresVariableInitalization, line: 2, column: 5)
            ],
            macros: testMacros
        )
    #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
    }
    
    func testMacroThowsWhenThePropertyTypeIsUnknown() throws {
    #if canImport(GlobalMacroMacros)
        let propertyType = "random"
        let invalidInput = """
        extension GlobalValues {
            @GlobalValue(propertyType: .\(propertyType)) var state: String = "Thing"
        }
        """
        
        let expectedOutput = """
        extension GlobalValues {
            var state: String {
                get {
                    self[__GlobalKey_state.self]
                }
                set {
                    self[__GlobalKey_state.self] = newValue
                }
            }
        }
        """
        
        assertMacroExpansion(
            invalidInput,
            expandedSource: expectedOutput,
            diagnostics: [
                DiagnosticSpec(from: .unknownPropertyType(propertyType), line: 2, column: 5)
            ],
            macros: testMacros
        )
    #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
    }
}
