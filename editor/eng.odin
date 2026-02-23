package editor

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"

import "../core/eaw"
import "../core/eau"
import "../core/ear"

import "_hook"
import "ui"
import "types"

// read by eat
used: bool

arena: ^eau.Arena
game_fb: ^ear.Framebuffer
    game_col: ^ear.Texture
    game_depth: ^ear.Texture

enabled: bool
flipped: bool

prev_mouse: eaw.MouseMode


hook :: proc() {
    used = true

    arena = eau.create_arena()

    ui.init(arena)

    game_col = ear.create_texture({ type = .Hdr }, nil, 1600,900, arena)
    game_depth = ear.create_texture({ type = .Depth }, nil, 1600,900, arena)
    game_fb = ear.create_framebuffer({
            out_colors = { game_col },
            out_depth = game_depth,
            width = 1600, height = 900,
        }, arena)
}

unhook :: proc() {
    arena->delete()

    used = false
}


before :: proc() {
    ear.set_default_framebuffer(game_fb)
    ear.bind_framebuffer(nil)
}

after :: proc() {
    ear.set_default_framebuffer(nil)
    ear.bind_framebuffer(nil)

    if flipped do ear.tex(game_col, 0,f32(eaw.height), f32(eaw.width),-f32(eaw.height), 1)
    else do ear.tex(game_col, 0,0, f32(eaw.width), f32(eaw.height), 1)

    if enabled {
        offx, heightsuby: f32 = 114./640.*f32(eaw.width), 94./360.*f32(eaw.height)
        if flipped do ear.tex(game_col, offx,f32(eaw.height)-heightsuby, f32(eaw.width)-64,-f32(eaw.height)+heightsuby, 1)
        else do ear.tex(game_col, offx,0, f32(eaw.width), f32(eaw.height)-heightsuby, 1)

        ear.bind_framebuffer(ui.edit_fb)
        ear.clear([4]f32{ 0,0,0,0 })

        mx, my := eaw.mouse.x*640./f32(eaw.width), eaw.mouse.y*360./f32(eaw.height)

        changed_sel := false

        ui.objects(mx,my, &changed_sel)
        ui.types(mx,my, &changed_sel)
        ui.info(mx,my, &changed_sel)

        if eaw.is_mouse_pressed(.Left) && !changed_sel do ui.selected = -1
    }
}

init_objects :: proc() {
    types.init_objects()
}

update_objects :: proc() {
    if enabled do return
    types.update_objects()
}

draw_objects :: proc() {
    types.draw_objects()
}

/*stop_objects :: proc() {
    types.stop_objects()
}*/
