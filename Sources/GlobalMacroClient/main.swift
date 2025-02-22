// Copyright © 2025 Ben Morrison. All rights reserved.

import Foundation
import Global
import GlobalMacros

enum GlobalState: String {
    case happy, sad, whoKnows
}

struct Thing {
    let name: String
}

extension GlobalValues {
    @GlobalValue var state: GlobalState = .whoKnows
    @GlobalValue var defaultInteger: Int = .min
}

final class Client: CustomStringConvertible {
    @Global(\.state) private var state: GlobalState
    
    func changeState(to: GlobalState) {
        state = to
    }
    
    func getState() -> GlobalState {
        return state
    }
    
    var description: String { "Client       state: \(state)" }
}

struct ClientViewer: CustomStringConvertible {
    @Global(\.state) var globalState: GlobalState
    
    var description: String { "ClientViewer State: \(globalState)" }
}

extension Int {
    @GlobalAccessor(\.defaultInteger, type: .getter) var `default`: Int
}

let client = Client()
let viewer = ClientViewer()

print(client)
print(viewer)
client.changeState(to: .happy)
print(client)
print(viewer)
client.changeState(to: .sad)
print(client)
print(viewer)
print(Int.max.default)

