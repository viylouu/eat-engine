package eat

import "core:fmt"

import "core/eaw"
import "core/ear"

init :: proc(
    width, height: i32,
    title: cstring,

    other: struct{
        vsync: Maybe(bool)
    }
) {
    eaw.init(width,height, title, other.vsync.? or_else true)
    ear.init()
}

stop :: proc() {
    ear.stop()
    eaw.stop()
}


frame :: proc() -> bool {
    if !eaw.is_open() do return false

    ear.frame()
    eaw.frame()

    return true
}
