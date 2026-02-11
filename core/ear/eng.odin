package ear

import "core:math/linalg/glsl"
import glfw "vendor:glfw"
import gl "vendor:OpenGL"

import "../eaw"
import "../eau"

init :: proc() {
    gl.load_up_to(4,3, glfw.gl_set_proc_address)

    gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)

    arena = eau.create_arena()

    rect_rend_create()
    tex_rend_create()
}

stop :: proc() {
    //tex_rend_delete()
    //rect_rend_delete()
    arena->delete()
}


frame :: proc() {
    bind_framebuffer(nil)
}
