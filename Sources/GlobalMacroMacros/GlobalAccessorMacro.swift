// Copyright © 2025 Ben Morrison. All rights reserved.

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GlobalAccessorMacro: AccessorMacro, GlobalMacroSupport {
    public static let macroName = "GlobalAccessor"
    static let keyPathArgumentName = "keyPath"
    static let methodArgumentName = "type"
    static let methodValueGetter = "getter"
    static let methodValueGetterAndSetter = "getterAndSetter"
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        let _ = try variableDeclaration(in: declaration)
        try ensureInProtocol(in: context)
                
        guard let keyPath = argument(from: node, first: { $0.expression.is(KeyPathExprSyntax.self) }) else {
            throw GlobalMacroError.missingRequiredArgument(keyPathArgumentName, forMacro: self)
        }
        
        let type = argumentNamed(methodArgumentName, from: node) {
            guard let memberAccess = $0?.expression.as(MemberAccessExprSyntax.self) else { return methodValueGetter }
            return memberAccess.declName.baseName.text
        }
        
        var retVal = [AccessorDeclSyntax("get { GlobalValues.get(\(keyPath.expression)) }")]
        if type == methodValueGetterAndSetter {
            retVal.append(AccessorDeclSyntax("set { GlobalValues.set(\(keyPath.expression), to: newValue) }"))
        }
        
        return retVal
    }
    
    
}
