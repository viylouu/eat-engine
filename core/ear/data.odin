package ear

import "core:math/linalg/glsl"

proj: glsl.mat4

rect_rend: struct{
    pln: Pipeline,
    ubo: Buffer,
        ubo_d: struct{ proj: glsl.mat4 },
    ssbo: Buffer,
        ssbo_d: [4096]struct{ pos: [2]f32, size: [2]f32, col: [4]f32 },
        ssbo_i: u32,
} = {}

rect_rend_create :: proc() {
    vert := #load("shaders/rect.vert", cstring)
    frag := #load("shaders/rect.frag", cstring)

    rect_rend.pln = create_pipeline({
        vertex = { source = &vert },
        fragment = { source = &frag },
    })

    rect_rend.ubo = create_buffer({
        type = .Uniform,
        usage = .Dynamic,
    }, &rect_rend.ubo_d, size_of(rect_rend.ubo_d))

    rect_rend.ssbo = create_buffer({
        type = .Storage,
        usage = .Dynamic,
    }, &rect_rend.ssbo_d, size_of(rect_rend.ssbo_d))
}

rect_rend_delete :: proc() {
    delete_buffer(rect_rend.ssbo)
    delete_buffer(rect_rend.ubo)
    delete_pipeline(rect_rend.pln)
}


tex_rend: struct{
    pln: Pipeline,
    ubo: Buffer,
        ubo_d: struct{ proj: glsl.mat4 },
    ssbo: Buffer,
        ssbo_d: [4096]struct{ pos: [2]f32, size: [2]f32, col: [4]f32 },
        ssbo_i: u32,
    cur_tex: ^Texture,
} = {}

tex_rend_create :: proc() {
    vert := #load("shaders/tex.vert", cstring)
    frag := #load("shaders/tex.frag", cstring)

    tex_rend.pln = create_pipeline({
        vertex = { source = &vert },
        fragment = { source = &frag },
    })

    tex_rend.ubo = create_buffer({
        type = .Uniform,
        usage = .Dynamic,
    }, &tex_rend.ubo_d, size_of(tex_rend.ubo_d))

    tex_rend.ssbo = create_buffer({
        type = .Storage,
        usage = .Dynamic,
    }, &tex_rend.ssbo_d, size_of(tex_rend.ssbo_d))
}

tex_rend_delete :: proc() {
    delete_buffer(tex_rend.ssbo)
    delete_buffer(tex_rend.ubo)
    delete_pipeline(tex_rend.pln)
}
