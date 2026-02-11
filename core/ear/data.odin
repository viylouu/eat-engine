package ear

import "core:math/linalg/glsl"

import "../eau"

arena: ^eau.Arena

@private
last_used: enum{
    Rect,
    Tex,
} = .Rect

proj: glsl.mat4

@private
rect_rend: struct{
    pln: ^Pipeline,
    ubo: ^Buffer,
        ubo_d: struct{ proj: glsl.mat4 },
    ssbo: ^Buffer,
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
        blend = BlendState{
            src_color = .SrcAlpha, dst_color = .InvSrcAlpha,
            color_op = .Add,
            src_alpha = .One, dst_alpha = .InvSrcAlpha,
            alpha_op = .Add,
        },
    }, arena)

    rect_rend.ubo = create_buffer({
        type = .Uniform,
        usage = .Dynamic,
        stride = size_of(rect_rend.ubo_d),
    }, &rect_rend.ubo_d, size_of(rect_rend.ubo_d), arena)

    rect_rend.ssbo = create_buffer({
        type = .Storage,
        usage = .Dynamic,
        stride = size_of(rect_rend.ssbo_d[0]),
    }, &rect_rend.ssbo_d, size_of(rect_rend.ssbo_d), arena)
}

/*@private
rect_rend_delete :: proc() {
    rect_rend.ssbo->delete()
    rect_rend.ubo->delete()
    rect_rend.pln->delete()
}*/

@private
flush_rect :: proc() {
    if rect_rend.ssbo_i == 0 do return

    rect_rend.ubo_d.proj = proj

    rect_rend.ubo->update()
    rect_rend.ssbo->update()

    rect_rend.pln->bind()
    rect_rend.ssbo->bind(0)
    rect_rend.ubo->bind(1)

    draw(6, int(rect_rend.ssbo_i))

    rect_rend.ssbo_i = 0
}


@private
tex_rend: struct{
    pln: ^Pipeline,
    ubo: ^Buffer,
        ubo_d: struct{ proj: glsl.mat4 },
    ssbo: ^Buffer,
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
        blend = BlendState{
            src_color = .SrcAlpha, dst_color = .InvSrcAlpha,
            color_op = .Add,
            src_alpha = .One, dst_alpha = .InvSrcAlpha,
            alpha_op = .Add,
        },
    }, arena)

    tex_rend.ubo = create_buffer({
        type = .Uniform,
        usage = .Dynamic,
        stride = size_of(tex_rend.ubo_d),
    }, &tex_rend.ubo_d, size_of(tex_rend.ubo_d), arena)

    tex_rend.ssbo = create_buffer({
        type = .Storage,
        usage = .Dynamic,
        stride = size_of(tex_rend.ssbo_d[0]),
    }, &tex_rend.ssbo_d, size_of(tex_rend.ssbo_d), arena)
}

/*@private
tex_rend_delete :: proc() {
    tex_rend.ssbo->delete()
    tex_rend.ubo->delete()
    tex_rend.pln->delete()
}*/

@private
flush_tex :: proc() {
    if tex_rend.ssbo_i == 0 do return

    tex_rend.ubo_d.proj = proj

    tex_rend.ubo->update()
    tex_rend.ssbo->update()

    tex_rend.pln->bind()
    tex_rend.ssbo->bind(0)
    tex_rend.ubo->bind(1)
    tex_rend.cur_tex->bind(2)

    draw(6, int(tex_rend.ssbo_i))

    tex_rend.ssbo_i = 0
}
