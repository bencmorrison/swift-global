// Copyright © 2025 Ben Morrison. All rights reserved.

#if canImport(GlobalMacroMacros)
import GlobalMacroMacros
import SwiftSyntaxMacrosTestSupport

extension DiagnosticSpec {
    init(from error: GlobalValueMacroError, line: Int, column: Int) {
        self.init(message: error.message, line: line, column: column)
    }
}

#endif
