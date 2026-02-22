package editor

import "../core/eaw"

toggle :: proc() {
    enabled = !enabled

    if enabled {
        prev_mouse = eaw.cur_mouse_mode
        eaw.mouse_mode(.Normal)
    } else do eaw.mouse_mode(prev_mouse)
}

flip_fb :: proc() {
    flipped = !flipped
}
