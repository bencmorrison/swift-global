// Copyright © 2025 Ben Morrison. All rights reserved.

import Testing
@testable import Global

@Suite(.serialized)
struct BasicTests {
    let customStorage: GlobalValues = .testStorage()
    let helperClass = HelperClass()
    let helperStruct = HelperStruct()
    
    @Test
    func testChangesPersistAcrossCalls() async throws {
        GlobalValues.setSharedStorage(customStorage)
        var currentValue = GlobalEnum.defaultValue
        
        #expect(currentValue == GlobalValues.shared[GlobalEnum.self])
        #expect(currentValue == helperClass.globalEnum)
        #expect(currentValue == helperStruct.globalEnum)
        
        helperClass.globalEnum = .known
        currentValue = .known
        #expect(currentValue == helperClass.globalEnum)
        #expect(currentValue == helperStruct.globalEnum)
        
        helperClass.globalEnum = .aThirdOption
        currentValue = .aThirdOption
        #expect(currentValue == helperClass.globalEnum)
        #expect(currentValue == helperStruct.globalEnum)
    }
}
