package main

import "core:fmt"
import eat "../../"

import "../../core/ear"

main :: proc() {
    eat.init(
            800, 600,
            "window",
        )
    defer eat.stop()

    for eat.frame() {
        ear.clear([3]f32{ .2, .4, .3 })

        ear.rect({ 0,0 }, { 64,64 }, [3]f32 { 1,0,0 })
    }
}
