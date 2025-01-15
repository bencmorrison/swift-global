// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GlobalValueMacro: GlobalMacroSupport {
    public static var macroName: String { "GlobalValue" }
    @usableFromInline static let extensionName: String = "GlobalValues"
    @usableFromInline static let prefix: String = "__GlobalKey_"
    @usableFromInline static let propertyTypeArgumentName: String = "propertyType"
    @usableFromInline static let propertyTypeNameComputed: String = "computed"
    @usableFromInline static let propertyTypeNameConstant: String = "constant"
    
    @inlinable
    static func defaultValue(from variableDecl: VariableDeclSyntax, andTypeAnnotation typeAnnotation: TypeSyntax) throws -> ExprSyntax {
        if typeAnnotation.as(OptionalTypeSyntax.self) != nil {
            return variableDecl.bindings.first?.initializer?.value ?? "nil"
        } else if let value = variableDecl.bindings.first?.initializer?.value {
            return value
        } else {
            throw GlobalMacroError.requiresVariableInitalization(macro: self)
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
        try ensureInProtocol(named: extensionName, in: context)

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
        
        try ensureInProtocol(named: extensionName, in: context)
        
        let typeAnnotation = try typeAnnotation(from: variableDecl)
        let keyName = "\(prefix)\(identifier.text)"
        let defaultValue = try defaultValue(from: variableDecl, andTypeAnnotation: typeAnnotation)
                
        let evaluationType = argumentNamed(propertyTypeArgumentName, from: node) {
            guard let memberAccess = $0?.expression.as(MemberAccessExprSyntax.self) else { return propertyTypeNameConstant }
            return memberAccess.declName.baseName.text
        }
        
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
            throw GlobalMacroError.unknownType(evaluationType, forMacro: self)
        }
        
        source += "}"
        
        return [
            DeclSyntax(stringLiteral: source)
        ]
        
    }
}
