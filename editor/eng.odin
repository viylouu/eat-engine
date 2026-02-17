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
        offx, heightsuby: f32 = 114./640.*f32(eaw.width), 94./360.*f32(eaw.height)
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
            ear.rect(114,360-94, 640-64,94, .2)
            ear.rect(115,361-94, 638-64,92, .1)

            changed_sel: bool

            x,y: int
            builders := make([]strings.Builder, len(_hook.objects))
            defer delete(builders)

            for obj,i in _hook.objects {
                if obj.data == nil do continue

                name := &builders[i]
                name^ = strings.builder_make()

                switch obj.type {
                case .Arena: strings.write_string(name, "arena ")
                case .Buffer: strings.write_string(name, "buffer ")
                case .Texture: strings.write_string(name, "texture ")
                case .Pipeline: strings.write_string(name, "pipeline ")
                case .TexArray: strings.write_string(name, "texarray ")
                case .Framebuffer: strings.write_string(name, "framebuffer ")
                case .None: strings.write_string(name, "#&(åæ@@")
                }
                strings.write_int(name, i)

                sname := strings.to_string(name^)
                text_width := (len(sname)) * int(font.width)/16
                x += text_width + 2
                if x+115 >= 640 {
                    x = text_width+2
                    y += int(font.height)/16 + 2
                }

                sel := eau.pointrect({mx,my}, { { f32(x)+117 - f32(text_width)-3, f32(y)+363-95 }, { f32(text_width)+1, f32(font.height)/16+1 }, .TopLeft, 0 })

                ear.rect(f32(x)+117 - f32(text_width)-3, f32(y)+363-95, f32(text_width)+1, f32(font.height)/16+1, sel || selected == i? .4 : .3)
                ear.rect(f32(x)+117 - f32(text_width)-2, f32(y)+363-94, f32(text_width)-1, f32(font.height)/16-1, sel || selected == i? .3 : .2)

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

                ear.text(font, sname, f32(x)+117 - f32(text_width)-2,f32(y)+363-94, 1,1)

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
            case .None: strings.write_string(&name, "#&(åæ@@")
            }
            strings.write_int(&name, selected)

            ear.text(font, strings.to_string(name), 118, 3, 1)

            strings.builder_reset(&name)

            offy: f32 = 3
            charh := f32(font.height)/16 + 1
            offy += charh

            redraw_thing()

            switch obj.type {
            case .None:
                ear.text(font, "...what? this object is removed. how are you seeing this?", 118, offy, 1)
            case .Arena:
                arena := (^eau.Arena)(obj.data)

                strings.write_string(&name, "objects:")
                strings.write_int(&name, len(arena.dests))

                ear.text(font, strings.to_string(name), 118, offy, 1)

                redraw_thing()
            case .Buffer:
                buf := (^ear.Buffer)(obj.data)

                type: string
                switch buf.desc.type {
                case .Vertex: type = "type:vertex"
                case .Uniform: type = "type:uniform"
                case .Storage: type = "type:storage"
                case .Index: type = "type:index"
                }
                ear.text(font, type, 118, offy, 1)

                offy += charh

                switch buf.desc.usage {
                case .Dynamic: ear.text(font, "usage:dynamic", 118, offy, 1)
                case .Static: ear.text(font, "usage:static", 118, offy, 1)
                }

                offy += charh

                strings.builder_reset(&name)
                strings.write_string(&name, "elements:")
                strings.write_u64(&name, u64(buf.size/buf.desc.stride))

                ear.text(font, strings.to_string(name), 118, offy, 1)

                offy += charh

                strings.builder_reset(&name)
                strings.write_string(&name, "stride:")
                strings.write_u64(&name, u64(buf.desc.stride))

                ear.text(font, strings.to_string(name), 118, offy, 1)

                redraw_thing()
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

                height := 127-offy
                ear.rect(118, offy, 124,height, 0)

                redraw_thing()
                ear.bind_framebuffer(nil)
               
                ear.tex(tex, 118./640.*f32(eaw.width), offy/360.*f32(eaw.height), 124/640.*f32(eaw.width),height/360.*f32(eaw.height), 1)
            case .Pipeline:
                pln := (^ear.Pipeline)(obj.data)

                ear.text(font, pln.desc.depth? "depth:enabled" : "depth:disabled", 118,offy, 1)

                offy += charh

                switch pln.desc.cull_mode {
                case .None: ear.text(font, "culling:none", 118, offy, 1)
                case .Front: ear.text(font, "culling:front", 118, offy, 1)
                case .Back: ear.text(font, "culling:back", 118, offy, 1)
                }

                offy += charh

                if pln.desc.cull_mode != .None {
                    switch pln.desc.front {
                    case .CW: ear.text(font, "front:cw", 118, offy, 1)
                    case .CCW: ear.text(font, "front:ccw", 118, offy, 1)
                    }
                    offy += charh
                }

                switch pln.desc.fill_mode {
                case .Fill: ear.text(font, "fill:fill", 118, offy, 1)
                case .Line: ear.text(font, "fill:line", 118, offy, 1)
                }

                offy += charh

                if blend, ok := pln.desc.blend.?; ok {
                    blendfac_add :: proc(builder: ^strings.Builder, fac: ear.BlendFactor) {
                        switch fac {
                        case .Zero: strings.write_string(builder, "zero")
                        case .One: strings.write_string(builder, "one")
                        case .SrcColor: strings.write_string(builder, "src-color")
                        case .InvSrcColor: strings.write_string(builder, "inv-src-color")
                        case .DstColor: strings.write_string(builder, "dst-color")
                        case .InvDstColor: strings.write_string(builder, "inv-dst-color")
                        case .SrcAlpha: strings.write_string(builder, "src-alpha")
                        case .InvSrcAlpha: strings.write_string(builder, "inv-src-alpha")
                        case .DstAlpha: strings.write_string(builder, "dst-alpha")
                        case .InvDstAlpha: strings.write_string(builder, "inv-dst-alpha")
                        }
                    }

                    blendop_add :: proc(builder: ^strings.Builder, op: ear.BlendOp) {
                        switch op {
                        case .Add: strings.write_string(builder, "add")
                        case .Subtract: strings.write_string(builder, "subtract")
                        case .RevSubtract: strings.write_string(builder, "rev-subtract")
                        case .Min: strings.write_string(builder, "min")
                        case .Max: strings.write_string(builder, "max")
                        }
                    }

                    add_thing :: proc(builder: ^strings.Builder, name: string, offy: ^f32, charh: f32, thing: union{ ear.BlendFactor, ear.BlendOp }) {
                        strings.builder_reset(builder)
                        strings.write_string(builder, name)
                        switch t in thing {
                        case ear.BlendFactor: blendfac_add(builder, t)
                        case ear.BlendOp: blendop_add(builder, t)
                        }

                        ear.text(font, strings.to_string(builder^), 118, offy^, 1)
                        offy^ += charh
                    }

                    ear.text(font, "blend state:", 118, offy, 1)
                    offy += charh

                    add_thing(&name, "- src-color:", &offy, charh, blend.src_color)
                    add_thing(&name, "- dst-color:", &offy, charh, blend.dst_color)
                    add_thing(&name, "- color-op:", &offy, charh, blend.color_op)
                    add_thing(&name, "- src-alpha:", &offy, charh, blend.src_alpha)
                    add_thing(&name, "- dst-alpha:", &offy, charh, blend.dst_alpha)
                    add_thing(&name, "- alpha-op:", &offy, charh, blend.alpha_op)
                } else do ear.text(font, "blending disabled", 118, offy, 1)

                offy += charh

                redraw_thing()
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
