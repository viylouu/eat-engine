package main

import "core:fmt"
import eat "../../"

import "../../core/eaw"
import "../../core/ear"

main :: proc() {
    eat.init(
            800, 600,
            "triangle",
        )
    defer eat.stop()

    fbtex := ear.create_texture({
            filter = .Nearest,
        }, nil, 128, 128)
    defer ear.delete_texture(fbtex)
    fb := ear.create_framebuffer({
            out_colors = { &fbtex },
        })
    defer ear.delete_framebuffer(fb)

    tex := ear.load_texture({
        filter = .Nearest,
    }, #load("tex.png"))
    defer ear.delete_texture(tex)

    for eat.frame() {
        ear.bind_framebuffer(fb)
        ear.clear([3]f32{ .2, .3, .4 })
        ear.tex(&tex, 0,0, 64,64, 1)

        ear.bind_framebuffer(nil)
        ear.tex(&fbtex, 0,0, f32(eaw.width), f32(eaw.height), 1)
    }
}
