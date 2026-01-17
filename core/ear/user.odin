package ear

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

clear :: proc{
    clear_rgba,
    clear_rgb,
}

clear_rgba :: proc(col: [4]f32) {
    gl.ClearColor(col.r, col.g, col.b, col.a)
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

clear_rgb :: proc(col: [3]f32) { clear_rgba([4]f32 { col.r, col.g, col.b, 1 }) }


draw :: proc(vertices: i32, instances: i32 = 1) {
    gl.DrawArraysInstanced(gl.TRIANGLES, 0, vertices, instances)
}



flush :: proc() {
    rect_rend.ubo_d.proj = proj

    update_buffer(&rect_rend.ubo)
    update_buffer(&rect_rend.ssbo)

    bind_pipeline(rect_rend.pln)
    bind_buffer(rect_rend.ssbo, 0)
    bind_buffer(rect_rend.ubo, 1)

    draw(6, i32(rect_rend.ssbo_i))

    rect_rend.ssbo_i = 0


    tex_rend.ubo_d.proj = proj

    update_buffer(&tex_rend.ubo)
    update_buffer(&tex_rend.ssbo)

    bind_pipeline(tex_rend.pln)
    bind_buffer(tex_rend.ssbo, 0)
    bind_buffer(tex_rend.ubo, 1)
    bind_texture(tex_rend.cur_tex^, 0)

    draw(6, i32(tex_rend.ssbo_i))

    tex_rend.ssbo_i = 0
}


rect :: proc{
    rect_rgba,
    rect_rgb,
    rect_rgba_vec,
    rect_rgb_vec,
}

rect_rgba :: proc(x, y: f32, w, h: f32, col: [4]f32) {
    if int(rect_rend.ssbo_i) == len(rect_rend.ssbo_d) do flush()

    rect_rend.ssbo_d[rect_rend.ssbo_i] = { pos = {x,y}, size = {w,h}, col = col }
    rect_rend.ssbo_i += 1
}

rect_rgb :: proc(x, y: f32, w, h: f32, col: [3] f32) { rect_rgba(x,y, w,h, [4]f32 { col.r, col.g, col.b, 1 }) }
rect_rgba_vec :: proc(pos: [2]f32, size: [2]f32, col: [4]f32) { rect_rgba(pos.x,pos.y, size.x,size.y, col) }
rect_rgb_vec :: proc(pos: [2]f32, size: [2]f32, col: [3]f32) { rect_rgba_vec(pos, size, [4]f32 { col.r, col.g, col.b, 1 }) }

tex :: proc{
    tex_rgba_wh_samp,
    tex_rgb_wh_samp,
    tex_ncol_wh_samp,
    tex_rgba_samp,
    tex_rgb_samp,
    tex_ncol_samp,
    tex_rgba_wh,
    tex_rgb_wh,
    tex_ncol_wh,
    tex_rgba,
    tex_rgb,
    tex_ncol,

    tex_rgba_wh_samp_vec,
    tex_rgb_wh_samp_vec,
    //tex_ncol_wh_samp_vec,
    tex_rgba_samp_vec,
    tex_rgb_samp_vec,
    //tex_ncol_samp_vec,
    tex_rgba_wh_vec,
    tex_rgb_wh_vec,
    tex_ncol_wh_vec,
    tex_rgba_vec,
    tex_rgb_vec,
    tex_ncol_vec,
}

tex_rgba_wh_samp :: proc(tex: ^Texture, x, y: f32, w, h: f32, sx,sy,sw,sh: f32, col: [4]f32) {
    if int(tex_rend.ssbo_i) == len(tex_rend.ssbo_d) do flush()
    if tex != tex_rend.cur_tex && tex_rend.cur_tex != nil do flush()

    tex_rend.cur_tex = tex

    tex_rend.ssbo_d[tex_rend.ssbo_i] = { pos = {x,y}, size = {w,h}, col = col, samp = { sx/f32(tex.width), sy/f32(tex.height), sw/f32(tex.width), sh/f32(tex.height) } }
    tex_rend.ssbo_i += 1
}

tex_rgb_wh_samp :: proc(tex: ^Texture, x, y: f32, w, h: f32, sx,sy,sw,sh: f32, col: [3]f32) { tex_rgba_wh_samp(tex, x,y, w,h, sx,sy,sw,sh, [4]f32{ col.r, col.g, col.b, 1 }) }
tex_ncol_wh_samp :: proc(tex: ^Texture, x, y: f32, w, h: f32, sx,sy,sw,sh: f32) { tex_rgb_wh_samp(tex, x,y, w,h, sx,sy,sw,sh, [3]f32{ 1,1,1 }) }
tex_rgba_samp :: proc(tex: ^Texture, x, y: f32, sx,sy,sw,sh: f32, col: [4]f32) { tex_rgba_wh_samp(tex, x,y, sw,sh, sx,sy,sw,sh, col) }
tex_rgb_samp :: proc(tex: ^Texture, x, y: f32, sx,sy,sw,sh: f32, col: [3]f32) { tex_rgb_wh_samp(tex, x,y, sw,sh, sx,sy,sw,sh, col) }
tex_ncol_samp :: proc(tex: ^Texture, x, y: f32, sx,sy,sw,sh: f32) { tex_ncol_wh_samp(tex, x,y, sw,sh, sx,sy,sw,sh) }
tex_rgba_wh :: proc(tex: ^Texture, x, y: f32, w, h: f32, col: [4]f32) { tex_rgba_samp(tex, x,y, 0,0, w,h, col) }
tex_rgb_wh :: proc(tex: ^Texture, x, y: f32, w, h: f32, col: [3]f32) { tex_rgb_samp(tex, x,y, 0,0, w,h, col) }
tex_ncol_wh :: proc(tex: ^Texture, x, y: f32, w, h: f32) { tex_ncol_samp(tex, x,y, 0,0, w,h) }
tex_rgba :: proc(tex: ^Texture, x, y: f32, col: [4]f32) { tex_rgba_wh(tex, x,y, f32(tex.width),f32(tex.height), col) }
tex_rgb :: proc(tex: ^Texture, x, y: f32, col: [3]f32) { tex_rgb_wh(tex, x,y, f32(tex.width),f32(tex.height), col) }
tex_ncol :: proc(tex: ^Texture, x, y: f32) { tex_ncol_wh(tex, x,y, f32(tex.width),f32(tex.height)) }

tex_rgba_wh_samp_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, samp: [4]f32, col: [4]f32) { tex_rgba_wh_samp(tex, pos.x,pos.y, size.x,size.y, samp.x,samp.y,samp.z,samp.w, col) }
tex_rgb_wh_samp_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, samp: [4]f32, col: [3]f32) { tex_rgba_wh_samp_vec(tex, pos, size, samp, [4]f32{ col.r, col.g, col.b, 1 }) }
//tex_ncol_wh_samp_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, samp: [4]f32) { tex_rgb_wh_samp_vec(tex, pos, size, samp, [3]f32{ 1,1,1 }) }
tex_rgba_samp_vec :: proc(tex: ^Texture, pos: [2]f32, samp: [4]f32, col: [4]f32) { tex_rgba_wh_samp_vec(tex, pos, {samp.z,samp.w}, samp, col) }
tex_rgb_samp_vec :: proc(tex: ^Texture, pos: [2]f32, samp: [4]f32, col: [3]f32) { tex_rgb_wh_samp_vec(tex, pos, {samp.z,samp.w}, samp, col) }
//tex_ncol_samp_vec :: proc(tex: ^Texture, pos: [2]f32, samp: [4]f32) { tex_ncol_wh_samp_vec(tex, pos, {samp.z,samp.w}, samp) }
tex_rgba_wh_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, col: [4]f32) { tex_rgba_samp_vec(tex, pos, {0,0,size.x,size.y}, col) }
tex_rgb_wh_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, col: [3]f32) { tex_rgb_samp_vec(tex, pos, {0,0,size.x,size.y}, col) }
tex_ncol_wh_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32) { tex_rgb_samp_vec(tex, pos, {0,0,size.x,size.y}, [3]f32{ 1,1,1 }) }
tex_rgba_vec :: proc(tex: ^Texture, pos: [2]f32, col: [4]f32) { tex_rgba_wh_vec(tex, pos, {f32(tex.width),f32(tex.height)}, col) }
tex_rgb_vec :: proc(tex: ^Texture, pos: [2]f32, col: [3]f32) { tex_rgb_wh_vec(tex, pos, {f32(tex.width),f32(tex.height)}, col) }
tex_ncol_vec :: proc(tex: ^Texture, pos: [2]f32) { tex_ncol_wh_vec(tex, pos, {f32(tex.width),f32(tex.height)}) }
