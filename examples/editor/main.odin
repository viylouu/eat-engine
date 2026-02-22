package main

import "core:fmt"

import eat "../../"
import "../../core/eaw"
import "../../core/ear"
import "../../editor"

main :: proc() {
    eat.init(
            1600, 900,
            "window",
            {}
        )
    defer eat.stop()

    editor.hook()
    defer editor.unhook()

    editor.flip_fb()

    MyObject :: struct{
        init: editor.ObjectProc "init",
        /*draw: editor.ObjectProc "draw",
        update: editor.ObjectProc "update",*/
        stop: editor.ObjectProc "stop",

        pos: [2]f32 "position",
        rot: f32 "rotation",
    }

    obj := editor.create_object(MyObject{ 
            init = editor.wrap_object_proc(proc(obj: ^editor.Object(MyObject)) { 
                fmt.println("GOOON")
            }),
            /*draw = editor.wrap_object_proc(proc(obj: ^editor.Object(MyObject)) {
                fmt.println("move")
            }),
            update = editor.wrap_object_proc(proc(obj: ^editor.Object(MyObject)) {
                fmt.println("eyeballs")
            }),*/
            stop = editor.wrap_object_proc(proc(obj: ^editor.Object(MyObject)) {
                fmt.println("aww")
            }),

            pos = { 32,64 },
            rot = 3.14159/2,
        })
    defer obj->delete()

    for eat.frame() {
        ear.clear([3]f32{ .2, .4, .3 })

        ear.rect({ 0,0 }, { 64,64 }, [3]f32 { 1,0,0 })

        if eaw.is_key_pressed(.F8) do editor.toggle()
    }
}
