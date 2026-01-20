package ear

import "core:math/linalg/glsl"

proj: glsl.mat4

@private
rect_rend: struct{
    pln: Pipeline,
    ubo: Buffer,
        ubo_d: struct{ proj: glsl.mat4 },
    ssbo: Buffer,
        ssbo_d: [4096]struct{ pos: [2]f32, size: [2]f32, col: [4]f32 },
        ssbo_i: u32,
} = {}

@private
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
        stride = size_of(rect_rend.ubo_d),
    }, &rect_rend.ubo_d, size_of(rect_rend.ubo_d))

    rect_rend.ssbo = create_buffer({
        type = .Storage,
        usage = .Dynamic,
        stride = size_of(rect_rend.ssbo_d[0]),
    }, &rect_rend.ssbo_d, size_of(rect_rend.ssbo_d))
}

@private
rect_rend_delete :: proc() {
    delete_buffer(rect_rend.ssbo)
    delete_buffer(rect_rend.ubo)
    delete_pipeline(rect_rend.pln)
}

@private
flush_rect :: proc() {
    if rect_rend.ssbo_i == 0 do return

    rect_rend.ubo_d.proj = proj

    update_buffer(&rect_rend.ubo)
    update_buffer(&rect_rend.ssbo)

    bind_pipeline(rect_rend.pln)
    bind_buffer(rect_rend.ssbo, 0)
    bind_buffer(rect_rend.ubo, 1)

    draw(6, int(rect_rend.ssbo_i))

    rect_rend.ssbo_i = 0
}


@private
tex_rend: struct{
    pln: Pipeline,
    ubo: Buffer,
        ubo_d: struct{ proj: glsl.mat4 },
    ssbo: Buffer,
        ssbo_d: [4096]struct{ pos: [2]f32, size: [2]f32, col: [4]f32, samp: [4]f32 },
        ssbo_i: u32,
    cur_tex: ^Texture,
} = {}

@private
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
        stride = size_of(tex_rend.ubo_d),
    }, &tex_rend.ubo_d, size_of(tex_rend.ubo_d))

    tex_rend.ssbo = create_buffer({
        type = .Storage,
        usage = .Dynamic,
        stride = size_of(tex_rend.ssbo_d[0]),
    }, &tex_rend.ssbo_d, size_of(tex_rend.ssbo_d))
}

@private
tex_rend_delete :: proc() {
    delete_buffer(tex_rend.ssbo)
    delete_buffer(tex_rend.ubo)
    delete_pipeline(tex_rend.pln)
}

@private
flush_tex :: proc() {
    if tex_rend.ssbo_i == 0 do return

    tex_rend.ubo_d.proj = proj

    update_buffer(&tex_rend.ubo)
    update_buffer(&tex_rend.ssbo)

    bind_pipeline(tex_rend.pln)
    bind_buffer(tex_rend.ssbo, 0)
    bind_buffer(tex_rend.ubo, 1)
    bind_texture(tex_rend.cur_tex^, 0)

    draw(6, int(tex_rend.ssbo_i))

    tex_rend.ssbo_i = 0
}
