package eat

import "core:fmt"

import "core/eaw"
import "core/ear"

time: f32
delta: f32

init :: proc(
    width, height: i32,
    title: cstring,
) {
    eaw.init(width,height, title)
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

    time = eaw.time
    delta = eaw.delta

    return true
}
