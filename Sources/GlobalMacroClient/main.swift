// Copyright © 2025 Ben Morrison. All rights reserved.

import Foundation
import Global
import GlobalMacro

enum GlobalState: String {
    case happy, sad, whoKnows
}

struct Thing {
    let name: String
}

extension GlobalValues {
    @GlobalValue var state: GlobalState = .whoKnows
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

