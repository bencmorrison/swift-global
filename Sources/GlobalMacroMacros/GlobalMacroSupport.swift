// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftSyntax
import SwiftSyntaxMacros

protocol GlobalMacroSupport: MacroNameProvider {
    static var macroName: String { get }
    static var prefix: String { get }
    
    static func variableDeclaration(in declaration: some DeclSyntaxProtocol) throws -> VariableDeclSyntax
    static func identifier(from variableDecl: VariableDeclSyntax) throws -> TokenSyntax
    static func typeAnnotation(from variableDecl: VariableDeclSyntax) throws -> TypeSyntax
    static func ensureInProtocol(named: String?, in context: some MacroExpansionContext) throws
    static func argument(from node: AttributeSyntax, first: (LabeledExprListSyntax.Element) -> Bool) -> LabeledExprListSyntax.Element?
    static func argumentNamed<T>(_ name: String, from node: AttributeSyntax, transform: (LabeledExprListSyntax.Element?) throws -> T) rethrows -> T
}

extension GlobalMacroSupport {
    @usableFromInline static var prefix: String { "__GlobalKey_" }
    
    @inlinable
    static func variableDeclaration(in declaration: some DeclSyntaxProtocol) throws -> VariableDeclSyntax {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            throw GlobalMacroError.requiresVariableDeclaration(macro: self)
        }
        return variableDecl
    }
    
    @inlinable
    static func identifier(from variableDecl: VariableDeclSyntax) throws -> TokenSyntax {
        guard let identifier = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw GlobalMacroError.invalidVariableDeclaration(macro: self)
        }
        return identifier
    }
    
    @inlinable
    static func typeAnnotation(from variableDecl: VariableDeclSyntax) throws -> TypeSyntax {
        guard let typeAnnotation = variableDecl.bindings.first?.typeAnnotation?.type else {
            throw GlobalMacroError.requiresTypeAnnotation(macro: self)
        }
        return typeAnnotation
    }
    
    @inlinable
    static func ensureInProtocol(named: String? = nil, in context: some MacroExpansionContext) throws {
        guard let extensionDecl = context.lexicalContext.compactMap({ $0.as(ExtensionDeclSyntax.self) }).first else {
            throw GlobalMacroError.requiresUseInExtension(forMacro: self)
        }
        
        guard let named else { return }
        
        guard let identifierSyntax = extensionDecl.extendedType.as(IdentifierTypeSyntax.self) else {
            throw MacroExpansionErrorMessage("Unable to get the Identifier from the extension the macro is being used in.")
        }
        guard identifierSyntax.name.text == named else {
            throw GlobalMacroError.requiresUseInExtension(named, forMacro: self)
        }
        
        return
    }
    
    @inlinable
    static func argument(from node: AttributeSyntax, first: (LabeledExprListSyntax.Element) -> Bool) -> LabeledExprListSyntax.Element? {
        guard let argumentList = node.arguments?.as(LabeledExprListSyntax.self) else { return nil }
        return argumentList.first(where: first)
    }
    
    @inlinable
    static func argumentNamed<T>(_ name: String, from node: AttributeSyntax, transform: (LabeledExprListSyntax.Element?) throws -> T) rethrows -> T {
        let argument = argument(from: node, first: { $0.label?.text == name })
        return try transform(argument)
    }
}
