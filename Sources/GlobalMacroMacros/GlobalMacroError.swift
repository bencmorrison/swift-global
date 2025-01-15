// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftDiagnostics

let diagnosticDomain: String = "GlobalMacroMacros"

public protocol MacroNameProvider {
    static var macroName: String { get }
}

public struct GlobalMacroError: Error, DiagnosticMessage, Equatable {
    public let message: String
    public let diagnosticID: MessageID
    public var severity: DiagnosticSeverity { .error }
    
    init(_ message: String) {
        self.message = message
        self.diagnosticID = .init(domain: diagnosticDomain, id: "\(Self.self)")
    }
}

extension GlobalMacroError {
    public static func requiresVariableDeclaration(macro: any MacroNameProvider.Type) -> Self {
        .init("@\(macro.macroName) can only be used with a variable declaration.")
    }
    
    public static func invalidVariableDeclaration(macro: any MacroNameProvider.Type) -> Self {
        .init("@\(macro.macroName) found an invalid variable declaration.")
    }
    
    public static func requiresUseInExtension(_ extensionName: String? = nil, forMacro macro: any MacroNameProvider.Type) -> Self {
        var message = "@\(macro.macroName) must be used in an extension"
        if let extensionName { message += " of \(extensionName)" }
        return .init(message)
    }
    
    public static func requiresTypeAnnotation(macro: any MacroNameProvider.Type) -> Self {
        .init("@\(macro.macroName) requires a type to be annotated for variable declarations.")
    }
    
    public static func requiresVariableInitalization(macro: any MacroNameProvider.Type) -> Self {
        .init("@\(macro.macroName) requires variable to be initialized, or must be marked as optional.")
    }
    
    public static func unknownType(_ type: String, forMacro macro: any MacroNameProvider.Type) -> Self {
        .init("@\(macro.macroName) found an unknown type: \(type).")
    }
    
    public static func missingRequiredArgument(_ argument: String, forMacro macro: any MacroNameProvider.Type) -> Self {
        .init("@\(macro.macroName) missing required argument: \(argument).")
    }
}
