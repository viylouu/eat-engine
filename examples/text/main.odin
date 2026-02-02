package main

import "core:fmt"
import eat "../../"

import "../../core/ear"

main :: proc() {
    eat.init(
            800, 600,
            "texture",
            {}
        )
    defer eat.stop()

    font := ear.load_texture({
        filter = .Nearest,
        type = .Color,
    }, #load("text.png"))
    defer font->delete()

    for eat.frame() {
        ear.clear([3]f32{ .2, .4, .3 })

        ear.text(&font, "hello\n\tworld!!!!", 0,0, 16, 1)
    }
}
