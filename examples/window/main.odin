package main

import "core:fmt"
import eat "../../"

import "../../core/ear"

main :: proc() {
    eat.init(
            800, 600,
            "game",
        )
    defer eat.stop()

    for eat.frame() {
        ear.clear([3]f32{ .2, .4, .3 })
    }
}
