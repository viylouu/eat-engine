package eaw

import "vendor:glfw"

KeyState :: enum{
    Released,
    Pressed,
    Held,
    Inactive,
}

Key :: enum{
    Escape,
    Caps,
    Space, Tab,
    Backspace, Delete,
    Home, End,
    PageUp, PageDown,
    Insert,

    LShift, RShift,
    LCtrl, RCtrl,
    LAlt, RAlt,
    LSuper, RSuper,

    Up, Left, Right, Down,

    A, B, C, D, E,
    F, G, H, I, J,
    K, L, M, N, O,
    P, Q, R, S, T,
    U, V, W, X, Y, Z,
    
    K1, K2, K3, K4, K5,
    K6, K7, K8, K9, K0,

    F1, F2, F3, F4,
    F5, F6, F7, F8,
    F9, F10, F11, F12,

    // add symbols and stuff
}

Mouse :: enum{
    Left, Right, Middle,
}


keys: [Key]KeyState
mousebuts: [Mouse]KeyState
mouse: [2]f32
mouse64: [2]f64
mouse_delta: [2]f32
mouse_delta64: [2]f64
mouse_scroll: [2]f32
mouse_scroll64: [2]f64
@private
lmouse64: [2]f64
lmouse_scroll64: [2]f64

is_key :: proc(key: Key) -> bool { return keys[key] == .Pressed || keys[key] == .Held }
is_key_pressed :: proc(key: Key) -> bool { return keys[key] == .Pressed }
is_key_released :: proc(key: Key) -> bool { return keys[key] == .Released }

is_mouse :: proc(mouse: Mouse) -> bool { return mousebuts[mouse] == .Pressed || mousebuts[mouse] == .Held }
is_mouse_pressed :: proc(mouse: Mouse) -> bool { return mousebuts[mouse] == .Pressed }
is_mouse_released :: proc(mouse: Mouse) -> bool { return mousebuts[mouse] == .Released }


MouseMode :: enum{
    Normal,
    Hidden,
    Locked,
}

mouse_mode :: proc(mode: MouseMode) {
    switch mode {
    case .Normal:
        glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_NORMAL)
    case .Hidden:
        glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_HIDDEN)
    case .Locked:
        glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    }
}


upk :: proc(key: Key, fw: i32) {
    prev := keys[key]
    keys[key] = glfw.GetKey(window, fw) == 1? .Pressed : .Released
    if keys[key] == .Pressed && ( prev == .Pressed || prev == .Held ) do keys[key] = .Held
    if keys[key] == .Released && ( prev == .Released || prev == .Inactive ) do keys[key] = .Inactive
}

upm :: proc(mouse: Mouse, fw: i32) {
    prev := mousebuts[mouse]
    mousebuts[mouse] = glfw.GetMouseButton(window, fw) == 1? .Pressed : .Released
    if mousebuts[mouse] == .Pressed && ( prev == .Pressed || prev == .Held ) do mousebuts[mouse] = .Held
    if mousebuts[mouse] == .Released && ( prev == .Released || prev == .Inactive ) do mousebuts[mouse] = .Inactive
}

update_keys :: proc() {
    upk(.Escape, glfw.KEY_ESCAPE)
    upk(.Caps, glfw.KEY_CAPS_LOCK)
    upk(.Space, glfw.KEY_SPACE)
    upk(.Tab, glfw.KEY_TAB)
    upk(.Backspace, glfw.KEY_BACKSPACE)
    upk(.Delete, glfw.KEY_DELETE)
    upk(.Home, glfw.KEY_HOME)
    upk(.End, glfw.KEY_END)
    upk(.PageUp, glfw.KEY_PAGE_UP)
    upk(.PageDown, glfw.KEY_PAGE_DOWN)
    upk(.Insert, glfw.KEY_INSERT)

    upk(.LShift, glfw.KEY_LEFT_SHIFT)
    upk(.RShift, glfw.KEY_RIGHT_SHIFT)
    upk(.LCtrl, glfw.KEY_LEFT_CONTROL)
    upk(.RCtrl, glfw.KEY_RIGHT_CONTROL)
    upk(.LAlt, glfw.KEY_LEFT_ALT)
    upk(.RAlt, glfw.KEY_RIGHT_ALT)
    upk(.LSuper, glfw.KEY_LEFT_SUPER)
    upk(.RSuper, glfw.KEY_RIGHT_SUPER)

    upk(.Up, glfw.KEY_UP)
    upk(.Left, glfw.KEY_LEFT)
    upk(.Right, glfw.KEY_RIGHT)
    upk(.Down, glfw.KEY_DOWN)

    for k in Key.A..=Key.Z do upk(k, i32(k-Key.A)+glfw.KEY_A)
    for k in Key.K1..=Key.K9 do upk(k, i32(k-Key.K1)+glfw.KEY_1)
        upk(.K0, glfw.KEY_0)
    for k in Key.F1..=Key.F12 do upk(k, i32(k-Key.F1)+glfw.KEY_F1)

    upm(.Left, glfw.MOUSE_BUTTON_LEFT)
    upm(.Right, glfw.MOUSE_BUTTON_RIGHT)
    upm(.Middle, glfw.MOUSE_BUTTON_MIDDLE)

    lmouse64 = mouse64
    mouse64.x, mouse64.y = glfw.GetCursorPos(window)
    mouse.x = f32(mouse64.x)
    mouse.y = f32(mouse64.y)
    mouse_delta64 = mouse64 - lmouse64
    mouse_delta.x = f32(mouse_delta64.x)
    mouse_delta.y = f32(mouse_delta64.y)
}

scroll_cb :: proc "c" (window: glfw.WindowHandle, xoff, yoff: f64) {
    lmouse_scroll64 = mouse_scroll64
    mouse_scroll64 = { xoff, yoff } - lmouse_scroll64
    mouse_scroll = { f32(mouse_scroll64.x), f32(mouse_scroll64.y) }
}

init_input :: proc() {
    glfw.SetScrollCallback(window, scroll_cb)
}
