package editor

import "core:strings"

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

selected: int = -1

hook :: proc() {
    used = true

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

        /* objects */ {
            ear.rect(0,0, 114,360, .1)
            ear.rect(1,1, 112,358, 0)
        }

        /* buffers and stuff */ {
            ear.rect(114,360-64, 640-64,64, .1)
            ear.rect(115,361-64, 638-64,62, 0)

            x,y: int
            for obj,i in _hook.objects {
                if obj.data == nil do continue

                name := strings.builder_make()
                defer strings.builder_destroy(&name)

                switch obj.type {
                case .Arena: strings.write_string(&name, "arena ")
                case .Buffer: strings.write_string(&name, "buffer ")
                case .Texture: strings.write_string(&name, "texture ")
                case .Pipeline: strings.write_string(&name, "pipeline ")
                case .TexArray: strings.write_string(&name, "texarray ")
                case .Framebuffer: strings.write_string(&name, "framebuffer ")
                }
                strings.write_int(&name, i)

                sname := strings.to_string(name)

                text_width := (len(sname)) * int(font.width)/16
                x += text_width + 2
                if x+115 >= 640 {
                    x = text_width+2
                    y += int(font.height)/16 + 2
                }

                ear.rect(f32(x)+117 - f32(text_width)-3, f32(y)+363-65, f32(text_width)+1, f32(font.height)/16+1, .2)
                ear.rect(f32(x)+117 - f32(text_width)-2, f32(y)+363-64, f32(text_width)-1, f32(font.height)/16-1, .1)

                ear.text(font, sname, f32(x)+117 - f32(text_width)-2,f32(y)+363-64, 1,1)
            }
        }

        ear.text(font, "editor", 2,2, 1)

        ear.bind_framebuffer(nil)
        ear.tex(edit_col, 0,f32(eaw.height), f32(eaw.width), -f32(eaw.height), 1)

        offx, heightsuby: f32 = 114./640.*f32(eaw.width), 64./360.*f32(eaw.height)

        if flipped do ear.tex(game_col, offx,f32(eaw.height)-heightsuby, f32(eaw.width)-64,-f32(eaw.height)+heightsuby, 1)
        else do ear.tex(game_col, offx,0, f32(eaw.width), f32(eaw.height)-heightsuby, 1)
    }
}
