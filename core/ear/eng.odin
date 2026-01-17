package ear

import "core:math/linalg/glsl"
import glfw "vendor:glfw"
import gl "vendor:OpenGL"

import "../eaw"

init :: proc() {
    gl.load_up_to(3,3, glfw.gl_set_proc_address)

    gl.Viewport(0,0, eaw.width, eaw.height)


    rect_rend_create()
    tex_rend_create()
}

stop :: proc() {
    tex_rend_delete()
    rect_rend_delete()
}


frame :: proc() {
    gl.Viewport(0,0, eaw.width, eaw.height)
    proj = glsl.mat4Ortho3d(0, f32(eaw.width), f32(eaw.height), 0, 0,1)
}
