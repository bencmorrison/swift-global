// Copyright © 2025 Ben Morrison. All rights reserved.

import Global

struct HelperStruct {
    @Global(\.globalEnum) var globalEnum
}

final class HelperClass {
    @Global(\.globalEnum) var globalEnum
}
