package ear

import "core:math/linalg/glsl"
import glfw "vendor:glfw"
import gl "vendor:OpenGL"

import "../eaw"

init :: proc() {
    gl.load_up_to(3,3, glfw.gl_set_proc_address)

    rect_rend_create()
    tex_rend_create()
}

stop :: proc() {
    tex_rend_delete()
    rect_rend_delete()
}


frame :: proc() {
    bind_framebuffer(nil)
}
