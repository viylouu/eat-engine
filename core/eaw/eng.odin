package eaw

import "core:fmt"
import "vendor:glfw"

window: glfw.WindowHandle
width, height: i32

init :: proc(
    w,h: i32,
    title: cstring,
) {
    assert(glfw.Init() != false)

    glfw.WindowHint(glfw.CLIENT_API, glfw.OPENGL_API)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)

    glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)

    width = w
    height = h

    window = glfw.CreateWindow(width, height, title, nil,nil)
    assert(window != nil)

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)

    glfw.SetWindowSize(window, width + 1, height)
    glfw.SetWindowSize(window, width, height)
}

stop :: proc() {
    glfw.MakeContextCurrent(nil)

    glfw.DestroyWindow(window)

    glfw.Terminate()
}


is_open :: proc() -> bool {
    return !glfw.WindowShouldClose(window)
}

frame :: proc() {
    glfw.SwapBuffers(window)
    glfw.PollEvents()

    width, height = glfw.GetWindowSize(window)
}
