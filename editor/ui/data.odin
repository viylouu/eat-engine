package editor_ui

import "../../core/eau"
import "../../core/ear"

colors: [16][3]f32

selected: int = -1
is_obj_selected: bool

font: ^ear.Texture

edit_fb: ^ear.Framebuffer
    edit_col: ^ear.Texture


init :: proc(arena: ^eau.Arena) {
    colors = {
        { 0,0,0 },
        { .1,.1,.1 },
        { .2,.2,.2 },
        { .3,.3,.3 },
        { .4,.4,.4 },
        { 0,0,0 },
        { 0,0,0 },
        { 0,0,0 },
        { 0,0,0 },
        { 0,0,0 },
        { 0,0,0 },
        { 0,0,0 },
        { 0,0,0 },
        { 0,0,0 },
        { 0,0,0 },
        { 1,1,1 },
    }

    edit_col = ear.create_texture({ type = .Color }, nil, 640,360, arena)
    edit_fb = ear.create_framebuffer({
            out_colors = { edit_col },
            width = 640, height = 360,
        }, arena)

    font = ear.load_texture({}, #load("../sprites/font.png"), arena)
}
