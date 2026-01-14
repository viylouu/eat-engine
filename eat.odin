package eat

import "core:fmt"

import "core/eaw"
import "core/ear"

init :: proc(
    width, height: i32,
    title: cstring,
) {
    fmt.println("init")

    eaw.init(width,height, title)
    ear.init()
}

stop :: proc() {
    fmt.println("stop")

    ear.stop()
    eaw.stop()
}


frame :: proc() -> bool {
    if !eaw.is_open() do return false

    eaw.frame()

    return true
}
