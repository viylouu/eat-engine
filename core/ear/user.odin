package ear

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
