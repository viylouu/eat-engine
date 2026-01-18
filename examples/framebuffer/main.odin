package main

import "core:fmt"
import eat "../../"

import "../../core/ear"

vtx: cstring = `
#version 330 core

const vec2 verts[6] = vec2[](
        vec2(-.5,-.5), vec2(-.5,.5), 
        vec2(.5,.5), vec2(.5,.5),
        vec2(.5,-.5), vec2(-.5,-.5)
    );

out vec2 fUv;

void main() {
    gl_Position = vec4(verts[gl_VertexID], 0,1);
    fUv = verts[gl_VertexID] + vec2(.5,.5);
}
`

frag: cstring = `
#version 430 core

in vec2 fUv;

layout (location = 0) uniform sampler2D tex;

out vec4 oCol;

void main() {
    oCol = texture(tex, fUv);
}
`

main :: proc() {
    eat.init(
            800, 600,
            "triangle",
        )
    defer eat.stop()

    pln := ear.create_pipeline({
            vertex = { source = &vtx },
            fragment = { source = &frag },
        })
    defer ear.delete_pipeline(pln)

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
        ear.clear([3]f32{ .2, .4, .3 })

        ear.bind_pipeline(pln)

        ear.bind_framebuffer(&fb)
        ear.clear([3]f32{ .2, .3, .4 })
        ear.bind_texture(tex, 0)
        ear.draw(6)

        ear.bind_framebuffer(nil)
        ear.bind_texture(fbtex, 0)
        ear.draw(6)
    }
}
