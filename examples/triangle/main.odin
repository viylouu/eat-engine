package main

import "core:fmt"

import eat "../../"
import "../../core/ear"

vtx: cstring = `
#version 330 core

const vec2 verts[3] = vec2[](
        vec2(0,.5), vec2(-.5,-.5), vec2(.5,-.5)
    );

void main() {
    gl_Position = vec4(verts[gl_VertexID], 0,1);
}
`

frag: cstring = `
#version 330 core

out vec4 col;

void main() {
    col = vec4(1,0,0,1);
}
`

main :: proc() {
    eat.init(
            800, 600,
            "triangle",
            {}
        )
    defer eat.stop()

    pln := ear.create_pipeline({
            vertex = { source = &vtx },
            fragment = { source = &frag },
        })
    defer pln->delete()

    for eat.frame() {
        ear.clear([3]f32{ .2, .4, .3 })

        pln->bind()
        ear.draw(3)
    }
}
