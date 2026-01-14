package ear

import glfw "vendor:glfw"
import gl "vendor:OpenGL"

import "../eaw"

init :: proc() {
    gl.load_up_to(3, 3, glfw.gl_set_proc_address)

    gl.Viewport(0,0, eaw.width, eaw.height)
}

stop :: proc() {
    
}
