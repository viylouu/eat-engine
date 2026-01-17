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

    tex := ear.load_texture({
        filter = .Nearest,
    }, #load("tex.png"))
    defer ear.delete_texture(tex)

    for eat.frame() {
        ear.clear([3]f32{ .2, .4, .3 })

        ear.tex(&tex, { 0,0 }, 1)

        ear.flush()
    }
}
