// Copyright © 2025 Ben Morrison. All rights reserved.

import Global

enum GlobalEnum {
    case unknown
    case known
    case aThirdOption
}

extension GlobalEnum: GlobalKey {
    static let defaultValue: GlobalEnum = .unknown
}

extension GlobalValues {
    var globalEnum: GlobalEnum {
        get { self[GlobalEnum.self] }
        set { self[GlobalEnum.self] = newValue }
    }
}
