// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftDiagnostics

fileprivate let diagnosticDomain: String = "GlobalMacroMacros"

public struct GlobalValueMacroError: Error, DiagnosticMessage, Equatable {
    public let message: String
    public let diagnosticID: MessageID
    public var severity: DiagnosticSeverity { .error }
    
    init(_ message: String) {
        self.message = message
        self.diagnosticID = .init(domain: diagnosticDomain, id: "\(Self.self)")
    }
}

extension GlobalValueMacroError {
    public static let requiresVariableDeclaration: GlobalValueMacroError = {
        .init("\(GlobalValueMacro.macroName) can only be used with a variable declaration.")
    }()
    
    public static let invalidVariableDeclaration: GlobalValueMacroError = {
        .init("Invalid variable declaration.")
    }()
    
    public static let requiresUseInGlobalValuesExtension: GlobalValueMacroError = {
        .init("\(GlobalValueMacro.macroName) must be used in an extension of \(GlobalValueMacro.globalValuesName)")
    }()
    
    public static let requiresTypeAnnotation: GlobalValueMacroError = {
        .init("\(GlobalValueMacro.macroName) requires a type to be annotated for variable declarations.")
    }()
    
    public static let requiresVariableInitalization: GlobalValueMacroError = {
        .init("Variable initialization required, or must be marked as optional.")
    }()
    
    public static func unknownPropertyType(_ type: String) -> GlobalValueMacroError {
        .init("Unknown type: PropertyType.\(type).")
    }
}
