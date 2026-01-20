ackage ear

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

draw_indexed :: proc(indices: []u32, instances: i32 = 1) {
    gl.DrawElementsInstanced(gl.TRIANGLES, len(indices), gl.UNSIGNED_INT, raw_data(indices), instances)
}



flush :: proc() {
    flush_rect()
    flush_tex()
}


rect :: proc{
    rect_rgba,
    rect_rgb,
    rect_gray,
    rect_rgba_vec,
    rect_rgb_vec,
    rect_gray_vec,
}

rect_rgba :: proc(x, y: f32, w, h: f32, col: [4]f32) {
    if int(rect_rend.ssbo_i) == len(rect_rend.ssbo_d) do flush_rect()

    rect_rend.ssbo_d[rect_rend.ssbo_i] = { pos = {x,y}, size = {w,h}, col = col }
    rect_rend.ssbo_i += 1
}

rect_rgb :: proc(x, y: f32, w, h: f32, col: [3] f32) { rect_rgba(x,y, w,h, [4]f32 { col.r, col.g, col.b, 1 }) }
rect_gray :: proc(x, y: f32, w, h: f32, col: f32) { rect_rgb(x,y, w,h, [3]f32 { col,col,col }) }
rect_rgba_vec :: proc(pos: [2]f32, size: [2]f32, col: [4]f32) { rect_rgba(pos.x,pos.y, size.x,size.y, col) }
rect_rgb_vec :: proc(pos: [2]f32, size: [2]f32, col: [3]f32) { rect_rgb(pos.x,pos.y, size.x,size.y, col) }
rect_gray_vec :: proc(pos: [2]f32, size: [2]f32, col: f32) { rect_gray(pos.x,pos.y, size.x,size.y, col) }

tex :: proc{
    tex_rgba_wh_samp,
    tex_rgb_wh_samp,
    tex_gray_wh_samp,
    tex_rgba_samp,
    tex_rgb_samp,
    tex_gray_samp,
    tex_rgba_wh,
    tex_rgb_wh,
    tex_gray_wh,
    tex_rgba,
    tex_rgb,
    tex_gray,

    tex_rgba_wh_samp_vec,
    tex_rgb_wh_samp_vec,
    tex_gray_wh_samp_vec,
    tex_rgba_samp_vec,
    tex_rgb_samp_vec,
    tex_gray_samp_vec,
    tex_rgba_wh_vec,
    tex_rgb_wh_vec,
    tex_gray_wh_vec,
    tex_rgba_vec,
    tex_rgb_vec,
    tex_gray_vec,
}

tex_rgba_wh_samp :: proc(tex: ^Texture, x, y: f32, w, h: f32, sx,sy,sw,sh: f32, col: [4]f32) {
    if int(tex_rend.ssbo_i) == len(tex_rend.ssbo_d) do flush_tex()
    if tex != tex_rend.cur_tex && tex_rend.cur_tex != nil do flush_tex()

    tex_rend.cur_tex = tex

    tex_rend.ssbo_d[tex_rend.ssbo_i] = { pos = {x,y}, size = {w,h}, col = col, samp = { sx/f32(tex.width), sy/f32(tex.height), sw/f32(tex.width), sh/f32(tex.height) } }
    tex_rend.ssbo_i += 1
}

tex_rgb_wh_samp :: proc(tex: ^Texture, x, y: f32, w, h: f32, sx,sy,sw,sh: f32, col: [3]f32) { tex_rgba_wh_samp(tex, x,y, w,h, sx,sy,sw,sh, [4]f32{ col.r, col.g, col.b, 1 }) }
tex_gray_wh_samp :: proc(tex: ^Texture, x, y: f32, w, h: f32, sx,sy,sw,sh: f32, col: f32) { tex_rgb_wh_samp(tex, x,y, w,h, sx,sy,sw,sh, [3]f32{ col,col,col }) }
tex_rgba_samp :: proc(tex: ^Texture, x, y: f32, sx,sy,sw,sh: f32, col: [4]f32) { tex_rgba_wh_samp(tex, x,y, sw,sh, sx,sy,sw,sh, col) }
tex_rgb_samp :: proc(tex: ^Texture, x, y: f32, sx,sy,sw,sh: f32, col: [3]f32) { tex_rgb_wh_samp(tex, x,y, sw,sh, sx,sy,sw,sh, col) }
tex_gray_samp :: proc(tex: ^Texture, x, y: f32, sx,sy,sw,sh: f32, col: f32) { tex_gray_wh_samp(tex, x,y, sw,sh, sx,sy,sw,sh, col) }
tex_rgba_wh :: proc(tex: ^Texture, x, y: f32, w, h: f32, col: [4]f32) { tex_rgba_wh_samp(tex, x,y, w,h, 0,0, f32(tex.width),f32(tex.height), col) }
tex_rgb_wh :: proc(tex: ^Texture, x, y: f32, w, h: f32, col: [3]f32) { tex_rgb_wh_samp(tex, x,y, w,h, 0,0, f32(tex.width),f32(tex.height), col) }
tex_gray_wh :: proc(tex: ^Texture, x, y: f32, w, h: f32, col: f32) { tex_gray_wh_samp(tex, x,y, w,h, 0,0, f32(tex.width),f32(tex.height), col) }
tex_rgba :: proc(tex: ^Texture, x, y: f32, col: [4]f32) { tex_rgba_wh(tex, x,y, f32(tex.width),f32(tex.height), col) }
tex_rgb :: proc(tex: ^Texture, x, y: f32, col: [3]f32) { tex_rgb_wh(tex, x,y, f32(tex.width),f32(tex.height), col) }
tex_gray :: proc(tex: ^Texture, x, y: f32, col: f32) { tex_gray_wh(tex, x,y, f32(tex.width),f32(tex.height), col) }

tex_rgba_wh_samp_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, samp: [4]f32, col: [4]f32) { tex_rgba_wh_samp(tex, pos.x,pos.y, size.x,size.y, samp.x,samp.y,samp.z,samp.w, col) }
tex_rgb_wh_samp_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, samp: [4]f32, col: [3]f32) { tex_rgba_wh_samp_vec(tex, pos, size, samp, [4]f32{ col.r, col.g, col.b, 1 }) }
tex_gray_wh_samp_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, samp: [4]f32, col: f32) { tex_rgb_wh_samp_vec(tex, pos, size, samp, [3]f32{ col,col,col }) }
tex_rgba_samp_vec :: proc(tex: ^Texture, pos: [2]f32, samp: [4]f32, col: [4]f32) { tex_rgba_wh_samp_vec(tex, pos, {samp.z,samp.w}, samp, col) }
tex_rgb_samp_vec :: proc(tex: ^Texture, pos: [2]f32, samp: [4]f32, col: [3]f32) { tex_rgb_wh_samp_vec(tex, pos, {samp.z,samp.w}, samp, col) }
tex_gray_samp_vec :: proc(tex: ^Texture, pos: [2]f32, samp: [4]f32, col: f32) { tex_gray_wh_samp_vec(tex, pos, {samp.z,samp.w}, samp, col) }
tex_rgba_wh_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, col: [4]f32) { tex_rgba_wh(tex, pos.x,pos.y, size.x,size.y, col) }
tex_rgb_wh_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, col: [3]f32) { tex_rgba_wh_vec(tex, pos, size, [4]f32 { col.r, col.g, col.b, 1 }) }
tex_gray_wh_vec :: proc(tex: ^Texture, pos: [2]f32, size: [2]f32, col: f32) { tex_rgb_wh_vec(tex, pos, size, [3]f32 { col,col,col }) }
tex_rgba_vec :: proc(tex: ^Texture, pos: [2]f32, col: [4]f32) { tex_rgba_wh_vec(tex, pos, {f32(tex.width),f32(tex.height)}, col) }
tex_rgb_vec :: proc(tex: ^Texture, pos: [2]f32, col: [3]f32) { tex_rgb_wh_vec(tex, pos, {f32(tex.width),f32(tex.height)}, col) }
tex_gray_vec :: proc(tex: ^Texture, pos: [2]f32, col: f32) { tex_gray_wh_vec(tex, pos, {f32(tex.width),f32(tex.height)}, col) }
