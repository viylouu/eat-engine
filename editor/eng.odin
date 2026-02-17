package editor

import "../core/eaw"
import "../core/eau"
import "../core/ear"

import "_hook"

// read by eat
used: bool

arena: ^eau.Arena
game_fb: ^ear.Framebuffer
    game_col: ^ear.Texture
    game_depth: ^ear.Texture
edit_fb: ^ear.Framebuffer
    edit_col: ^ear.Texture
    edit_depth: ^ear.Texture

font: ^ear.Texture

enabled: bool
flipped: bool

hook :: proc() {
    used = true
    _hook.init()
    _hook.hooked = true

    arena = eau.create_arena()

    game_col = ear.create_texture({ type = .Color }, nil, 1600,900, arena)
    game_depth = ear.create_texture({ type = .Depth }, nil, 1600,900, arena)
    game_fb = ear.create_framebuffer({
            out_colors = { game_col },
            out_depth = game_depth,
            width = 1600, height = 900,
        }, arena)

    edit_col = ear.create_texture({ type = .Color }, nil, 640,360, arena)
    edit_depth = ear.create_texture({ type = .Depth }, nil, 640,360, arena)
    edit_fb = ear.create_framebuffer({
            out_colors = { edit_col },
            out_depth = edit_depth,
            width = 640, height = 360,
        }, arena)

    font = ear.load_texture({}, #load("sprites/font.png"), arena)
}

unhook :: proc() {
    arena->delete()

    _hook.hooked = false
    _hook.stop()
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
        ear.bind_framebuffer(edit_fb)
        ear.clear([4]f32{ 0,0,0,0 })

        ear.rect(0,0, 64,360, [4]f32{ 0,0,0,1 })

        ear.text(font, "editor", 1,1, 1)

        ear.bind_framebuffer(nil)
        ear.tex(edit_col, 0,f32(eaw.height), f32(eaw.width), -f32(eaw.height), 1)

    }
}
