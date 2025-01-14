// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GlobalValueMacro {
    @usableFromInline static let macroName: String = "@GlobalValue"
    @usableFromInline static let globalValuesName: String = "GlobalValues"
    @usableFromInline static let prefix: String = "__GlobalKey_"
    @usableFromInline static let propertyTypeArgumentName: String = "propertyType"
    @usableFromInline static let propertyTypeNameComputed: String = "computed"
    @usableFromInline static let propertyTypeNameConstant: String = "constant"
    
    @inlinable
    static func variableDeclaration(in declaration: some DeclSyntaxProtocol) throws -> VariableDeclSyntax {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            throw GlobalValueMacroError.requiresVariableDeclaration
        }
        return variableDecl
    }
    
    @inlinable
    static func identifier(from variableDecl: VariableDeclSyntax) throws -> TokenSyntax {
        guard let identifier = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw GlobalValueMacroError.invalidVariableDeclaration
        }
        return identifier
    }
    
    @inlinable
    static func typeAnnotation(from variableDecl: VariableDeclSyntax) throws -> TypeSyntax {
        guard let typeAnnotation = variableDecl.bindings.first?.typeAnnotation?.type else {
            throw GlobalValueMacroError.requiresTypeAnnotation
        }
        return typeAnnotation
    }
    
    @inlinable
    static func ensureGlobalValuesProtocol(in context: some MacroExpansionContext) throws {
        guard let extensionDecl = context.lexicalContext.compactMap({ $0.as(ExtensionDeclSyntax.self) }).first else {
            throw GlobalValueMacroError.requiresUseInGlobalValuesExtension
        }
        guard let identifierSyntax = extensionDecl.extendedType.as(IdentifierTypeSyntax.self) else {
            throw MacroExpansionErrorMessage("Unable to get the Identifier from the extension the macro is being used in.")
        }
        guard identifierSyntax.name.text == globalValuesName else {
            throw GlobalValueMacroError.requiresUseInGlobalValuesExtension
        }
        
        return
    }
    
    @inlinable
    static func argumentNamed<T>(_ argumentName: String, from node: AttributeSyntax, parseFrom parse: (LabeledExprListSyntax.Element) -> T?) -> T? {
        guard let argumentList = node.arguments?.as(LabeledExprListSyntax.self) else { return nil }
        for argument in argumentList {
            if argument.label?.text == argumentName {
                return parse(argument)
            }
        }
        return nil
    }
    
    @inlinable
    static func defaultValue(from variableDecl: VariableDeclSyntax, andTypeAnnotation typeAnnotation: TypeSyntax) throws -> ExprSyntax {
        if typeAnnotation.as(OptionalTypeSyntax.self) != nil {
            return variableDecl.bindings.first?.initializer?.value ?? "nil"
        } else if let value = variableDecl.bindings.first?.initializer?.value {
            return value
        } else {
            throw GlobalValueMacroError.requiresVariableInitalization
        }
    }
}

extension GlobalValueMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        let variableDecl = try variableDeclaration(in: declaration)
        let identifier = try identifier(from: variableDecl)
        try ensureGlobalValuesProtocol(in: context)

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
        let variableDecl = try variableDeclaration(in: declaration)
        let identifier = try identifier(from: variableDecl)
        
        try ensureGlobalValuesProtocol(in: context)
        
        let typeAnnotation = try typeAnnotation(from: variableDecl)
        let keyName = "\(prefix)\(identifier.text)"
        let defaultValue = try defaultValue(from: variableDecl, andTypeAnnotation: typeAnnotation)
                
        let evaluationType = argumentNamed(propertyTypeArgumentName, from: node, parseFrom: { argument in
            if let memberAccess = argument.expression.as(MemberAccessExprSyntax.self) {
                return memberAccess.declName.baseName.text
            }
            return nil
        }) ?? propertyTypeNameConstant
        
        var source: String = """
        private struct \(keyName): GlobalKey {
            typealias Value = \(typeAnnotation)
        """
        
        switch evaluationType {
        case propertyTypeNameConstant:
            source += """
                static let defaultValue: Value = \(defaultValue)
            """
        case propertyTypeNameComputed:
            source += """
                static var defaultValue: Value { \(defaultValue) }
            """
        default:
            throw GlobalValueMacroError.unknownPropertyType(evaluationType)
        }
        
        source += "}"
        
        return [
            DeclSyntax(stringLiteral: source)
        ]
        
    }
}

@main
struct GlobalMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GlobalValueMacro.self,
    ]
}

