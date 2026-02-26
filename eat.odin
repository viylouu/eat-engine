package eat

import "core:fmt"

import "core/eaw"
import "core/ear"
//import "core/eaa"

import "editor"
import "editor/_hook"

// use this instead of the eaw fields
// - unless you want the window's width
// this will get changed by the editor for draw area width/height
// also, the time field is changed from the editor to not change when the editor is on
// this is because the editor pauses updates
width, height: u32
time, delta: f32

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
    //eaa.init()
    
    width  = u32(_width)
    height = u32(_height)
}

stop :: proc() {
    //eaa.stop()
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

        if !editor.enabled {
            delta = eaw.delta
            time += delta
        }
    } else {
        width = u32(eaw.width)
        height = u32(eaw.height)

        time = eaw.time
        delta = eaw.delta
    }

    return true
}
