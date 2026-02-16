package main

import "core:fmt"
import eat "../../"

import "../../core/eaw"
import "../../core/ear"

main :: proc() {
    eat.init(
            800, 600,
            "framebuffer",
            {}
        )
    defer eat.stop()

    fbtex := ear.create_texture({
            filter = .Nearest,
        }, nil, 128, 128)
    defer fbtex->delete()
    fb := ear.create_framebuffer({
            out_colors = { fbtex },
            width = 128,
            height = 128,
        })
    defer fb->delete()

    tex := ear.load_texture({
        filter = .Nearest,
        type = .Color,
    }, #load("tex.png"))
    defer tex->delete()

    for eat.frame() {
        fb->bind()
        ear.clear([3]f32{ .2, .3, .4 })
        ear.tex(tex, 0,0, 64,64, 1)

        ear.bind_framebuffer(nil)
        ear.tex(fbtex, 0,f32(eaw.height), f32(eaw.width), -f32(eaw.height), 1)
    }
}
