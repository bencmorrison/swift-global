// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GlobalValueMacro {
    fileprivate static let macroName: String = "@GlobalValue"
    fileprivate static let globalValuesName: String = "GlobalValues"
    fileprivate static let prefix: String = "__GlobalKey_"
    
    fileprivate static func ensureGlobalValuesProtocol(in context: some MacroExpansionContext) -> Error? {
        guard let extensionDecl = context.lexicalContext.compactMap({ $0.as(ExtensionDeclSyntax.self) }).first else {
            return MacroExpansionErrorMessage("There was an issue attempting to get the name of type the macro is being used in.")
        }
        guard let identifierSyntax = extensionDecl.extendedType.as(IdentifierTypeSyntax.self) else {
            return MacroExpansionErrorMessage("Unable to get the Identifier from the extension the macro is being used in.")
        }
        guard identifierSyntax.name.text == globalValuesName else {
            return MacroExpansionErrorMessage("\(macroName) must be used in an extension of \(globalValuesName)")
        }
        
        return nil
    }
}

extension GlobalValueMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("\(macroName) can only be used with a variable declaration.")
        }
        
        guard let identifier = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw MacroExpansionErrorMessage("Invalid variable declaration.")
        }
        
        if let error = ensureGlobalValuesProtocol(in: context) {
            throw error
        }

        let keyName = "\(prefix)\(identifier.text)"

        return [
            AccessorDeclSyntax("get { self[\(raw: keyName).self] }"),
            AccessorDeclSyntax("set { self[\(raw: keyName).self] = newValue }")
        ]
    }
}

extension GlobalValueMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("\(macroName) can only be used with a variable declaration.")
        }
        
        guard let identifier = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw MacroExpansionErrorMessage("Invalid variable declaration.")
        }
        
        guard let typeAnnotation = variableDecl.bindings.first?.typeAnnotation?.type else {
            throw MacroExpansionErrorMessage("Invalid variable type declaration.")
        }

        if let error = ensureGlobalValuesProtocol(in: context) {
            throw error
        }
        
        let keyName = "\(prefix)\(identifier.text)"
        
        let defaultValue = if typeAnnotation.as(OptionalTypeSyntax.self) != nil {
            variableDecl.bindings.first?.initializer?.value ?? "nil"
        } else if let value = variableDecl.bindings.first?.initializer?.value {
            value
        } else {
            throw MacroExpansionErrorMessage("Variable initialization required, or must be marked as optional.")
        }
        
        return [
            DeclSyntax(
            """
            private struct \(raw: keyName): GlobalKey {
                typealias Value = \(typeAnnotation)
                static var defaultValue: Value { \(defaultValue) }
            }
            """
            )
        ]
    }
}

@main
struct GlobalMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GlobalValueMacro.self,
    ]
}
