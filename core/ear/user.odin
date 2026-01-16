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
