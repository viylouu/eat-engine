package editor

import "core:fmt"
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
    edit_fb = ear.create_framebuffer({
            out_colors = { edit_col },
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
        offx, heightsuby: f32 = 114./640.*f32(eaw.width), 64./360.*f32(eaw.height)
        if flipped do ear.tex(game_col, offx,f32(eaw.height)-heightsuby, f32(eaw.width)-64,-f32(eaw.height)+heightsuby, 1)
        else do ear.tex(game_col, offx,0, f32(eaw.width), f32(eaw.height)-heightsuby, 1)

        ear.bind_framebuffer(edit_fb)
        ear.clear([4]f32{ 0,0,0,0 })

        mx, my := eaw.mouse.x*640./f32(eaw.width), eaw.mouse.y*360./f32(eaw.height)

        /* objects */ {
            ear.rect(0,0, 114,360, .2)
            ear.rect(1,1, 112,358, .1)

            ear.text(font, "editor", 2,2, 1)
        }

        /* buffers and stuff */ {
            ear.rect(114,360-64, 640-64,64, .2)
            ear.rect(115,361-64, 638-64,62, .1)

            changed_sel: bool

            x,y: int
            builders := make([]strings.Builder, len(_hook.objects))
            defer delete(builders)

            for obj,i in _hook.objects {
                name := &builders[i]
                name^ = strings.builder_make()

                switch obj.type {
                case .Arena: strings.write_string(name, "arena ")
                case .Buffer: strings.write_string(name, "buffer ")
                case .Texture: strings.write_string(name, "texture ")
                case .Pipeline: strings.write_string(name, "pipeline ")
                case .TexArray: strings.write_string(name, "texarray ")
                case .Framebuffer: strings.write_string(name, "framebuffer ")
                }
                strings.write_int(name, i)

                sname := strings.to_string(name^)
                text_width := (len(sname)) * int(font.width)/16
                x += text_width + 2
                if x+115 >= 640 {
                    x = text_width+2
                    y += int(font.height)/16 + 2
                }

                sel := eau.pointrect({mx,my}, { { f32(x)+117 - f32(text_width)-3, f32(y)+363-65 }, { f32(text_width)+1, f32(font.height)/16+1 }, .TopLeft, 0 })

                ear.rect(f32(x)+117 - f32(text_width)-3, f32(y)+363-65, f32(text_width)+1, f32(font.height)/16+1, sel || selected == i? .4 : .3)
                ear.rect(f32(x)+117 - f32(text_width)-2, f32(y)+363-64, f32(text_width)-1, f32(font.height)/16-1, sel || selected == i? .3 : .2)

                if sel && eaw.is_mouse_pressed(.Left) {
                    selected = i
                    changed_sel = true
                }
            }

            x, y = 0, 0
            for obj,i in _hook.objects {
                if obj.data == nil do continue

                name := &builders[i]
                sname := strings.to_string(name^)

                text_width := (len(sname)) * int(font.width)/16
                x += text_width + 2
                if x+115 >= 640 {
                    x = text_width+2
                    y += int(font.height)/16 + 2
                }

                ear.text(font, sname, f32(x)+117 - f32(text_width)-2,f32(y)+363-64, 1,1)

                strings.builder_destroy(name)
            }

            if eaw.is_mouse_pressed(.Left) && !changed_sel do selected = -1
        }
        
        redraw_thing :: proc() {
            ear.bind_framebuffer(nil)
            ear.tex(edit_col, 0,f32(eaw.height), f32(eaw.width), -f32(eaw.height), 1)   
            ear.bind_framebuffer(edit_fb)
        }

        redraw_thing()

        /* info */ if selected != -1 {
            ear.rect(116,1, 128,128, .2)
            ear.rect(117,2, 126,126, .1)

            obj := &_hook.objects[selected]

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
            strings.write_int(&name, selected)

            ear.text(font, strings.to_string(name), 118, 3, 1)

            strings.builder_reset(&name)

            offy: f32 = 3
            charh := f32(font.height)/16 + 1
            offy += charh

            redraw_thing()

            switch obj.type {
            case .Arena:
                arena := (^eau.Arena)(obj.data)

                strings.write_string(&name, "objects:")
                strings.write_int(&name, len(arena.dests))

                ear.text(font, strings.to_string(name), 118, offy, 1)

                redraw_thing()
            case .Buffer:
            case .Texture:
                tex := (^ear.Texture)(obj.data)

                strings.write_string(&name, "width:")
                strings.write_u64(&name, u64(tex.width))
                strings.write_string(&name, ", height:")
                strings.write_u64(&name, u64(tex.height))

                ear.text(font, strings.to_string(name), 118, offy, 1)
                
                offy += charh

                switch tex.desc.type {
                case .Color: ear.text(font, "type:color", 118, offy, 1)
                case .Depth: ear.text(font, "type:depth", 118, offy, 1)
                }

                offy += charh

                height := 126-offy
                ear.rect(118, offy, 124,height, 0)

                redraw_thing()
                ear.bind_framebuffer(nil)
               
                ear.tex(tex, 118./640.*f32(eaw.width), offy/360.*f32(eaw.height), 124/640.*f32(eaw.width),height/360.*f32(eaw.height), 1)
            case .Pipeline:
            case .TexArray:
            case .Framebuffer:
                fb := (^ear.Framebuffer)(obj.data)

                strings.write_string(&name, "width:")
                strings.write_u64(&name, u64(fb.desc.width))
                strings.write_string(&name, ", height:")
                strings.write_u64(&name, u64(fb.desc.height))

                ear.text(font, strings.to_string(name), 118, offy, 1)

                strings.builder_reset(&name)

                for _,i in fb.desc.out_colors {
                    col := fb.desc.out_colors[i]
                    if col == nil do continue

                    offy += charh
                    strings.write_string(&name, "- color tex ")
                    strings.write_int(&name, col^.idx)
                    
                    ear.text(font, strings.to_string(name), 118, offy, 1)

                    strings.builder_reset(&name)
                }
                
                if fb.desc.out_depth != nil {
                    offy += charh
                    strings.write_string(&name, "- depth tex ")
                    strings.write_int(&name, fb.desc.out_depth.idx)

                    ear.text(font, strings.to_string(name), 118, offy, 1)
                }

                redraw_thing()
            }
        }  
    }
}
