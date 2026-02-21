package eat

import "core:fmt"

import "core/eaw"
import "core/ear"

import "editor"
import "editor/_hook"

// use this instead of the eaw fields
// - unless you want the window's width
// this will get changed by the editor for draw area width/height
width, height: u32

@(private)
has_framed: bool

init :: proc(
    _width, _height: i32,
    title: cstring,

    other: struct{
        vsync: Maybe(bool)
    }
) {
    _hook.init()

    eaw.init(_width,_height, title, other.vsync.? or_else true)
    ear.init()
    
    width  = u32(_width)
    height = u32(_height)
}

stop :: proc() {
    editor.stop_objects()

    ear.stop()
    eaw.stop()

    _hook.stop()
}


frame :: proc() -> bool {
    if !eaw.is_open() do return false

    if editor.used do editor.after()

    ear.frame()
    eaw.frame()

    if editor.used {
        editor.before()

        width = 1600
        height = 900

        if !has_framed {
            editor.init_objects()
        } has_framed = true

        editor.update_objects()
        editor.draw_objects()
    } else {
        width = u32(eaw.width)
        height = u32(eaw.height)
    }

    return true
}
