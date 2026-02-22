package editor_ui

import "core:strings"

import "../../core/ear"
import "../../core/eau"
import "../../core/eaw"

import "../_hook"
import "info"
import "../types"

info :: proc() {
    redraw_thing :: proc() {
        ear.bind_framebuffer(nil)
        ear.tex(edit_col, 0,f32(eaw.height), f32(eaw.width), -f32(eaw.height), 1)   
        ear.bind_framebuffer(edit_fb)
    }

    redraw_thing()

    if selected != -1 {
        ear.rect(116,1, 128,128, colors[2])
        ear.rect(117,2, 126,126, colors[1])

        if !is_obj_selected do info_non_obj(redraw_thing)
        else do info_obj(redraw_thing)
    }  
}

info_non_obj :: proc(redraw_thing: proc()) {
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

    ear.text(font, strings.to_string(name), 118, 3, colors[15])

    strings.builder_reset(&name)

    offy: f32 = 3
    charh := f32(font.height)/16 + 1
    offy += charh

    ear.rect(118,offy, 126,1, colors[2])
    offy += 2

    redraw_thing()

    switch obj.type {
    case .None: info.none(font, offy, colors[15], redraw_thing)
    case .Arena: info.arena(font, obj, &name, offy, colors[15], redraw_thing)
    case .Buffer: info.buffer(font, obj, &name, offy, colors[15], redraw_thing)
    case .Texture: info.texture(font, obj, &name, offy, colors[15], redraw_thing)
    case .Pipeline: info.pipeline(font, obj, &name, offy, colors[15], redraw_thing, colors[1])
    case .TexArray: info.texarray(font, obj, &name, offy, colors[15], redraw_thing)
    case .Framebuffer: info.framebuffer(font, obj, &name, offy, colors[15], redraw_thing)
    }
}

info_obj :: proc(redraw_thing: proc()) {
    i := 0
    item := types.init_obj
    for item != nil {
        if i != selected {
            item = item.next
            i += 1
            continue
        }

        obj := (^types.Object(any))(item.obj)

        ear.text(font, obj.name, 118, 3, colors[15])

        offy: f32 = 3
        charh := f32(font.height)/16 + 1
        offy += charh

        ear.rect(118,offy, 126,1, colors[2])
        offy += 2

        name := strings.builder_make()
        defer strings.builder_destroy(&name)

        if obj.pos2d != nil {
            strings.write_string(&name, "pos:")
            strings.write_f32(&name, obj.pos2d.x, 'f')
            strings.write_rune(&name, ',')
            strings.write_f32(&name, obj.pos2d.y, 'f')

            ear.text(font, strings.to_string(name), 118, offy, colors[15])
            offy += charh
        } if obj.pos2d64 != nil {
            strings.write_string(&name, "pos:")
            strings.write_f64(&name, obj.pos2d64.x, 'f')
            strings.write_rune(&name, ',')
            strings.write_f64(&name, obj.pos2d64.y, 'f')

            ear.text(font, strings.to_string(name), 118, offy, colors[15])
            offy += charh
        } if obj.pos3d != nil {
            strings.write_string(&name, "pos:")
            strings.write_f32(&name, obj.pos3d.x, 'f')
            strings.write_rune(&name, ',')
            strings.write_f32(&name, obj.pos3d.y, 'f')
            strings.write_rune(&name, ',')
            strings.write_f32(&name, obj.pos3d.z, 'f')

            ear.text(font, strings.to_string(name), 118, offy, colors[15])
            offy += charh
        } if obj.pos3d64 != nil {
            strings.write_string(&name, "pos:")
            strings.write_f64(&name, obj.pos3d64.x, 'f')
            strings.write_rune(&name, ',')
            strings.write_f64(&name, obj.pos3d64.y, 'f')
            strings.write_rune(&name, ',')
            strings.write_f64(&name, obj.pos3d64.z, 'f')

            ear.text(font, strings.to_string(name), 118, offy, colors[15])
            offy += charh
        }

        /*strings.builder_reset(&name)
        strings.write_string(&name, "rot:")
        strings.write_f32(&name, obj.rot.x, 'f')
        strings.write_rune(&name, ',')
        strings.write_f32(&name, obj.rot.y, 'f')
        strings.write_rune(&name, ',')
        strings.write_f32(&name, obj.rot.z, 'f')

        ear.text(font, strings.to_string(name), 118, offy, colors[15])
        offy += charh*/

        has_funcs: bool
        strings.builder_reset(&name)
        strings.write_string(&name, "funcs:")

        if obj.tag_funcs.init != nil {
            strings.write_string(&name, "init")
            has_funcs = true
        }

        if obj.tag_funcs.update != nil {
            if has_funcs do strings.write_rune(&name, ',')
            strings.write_string(&name, "update")
            has_funcs = true
        }

        if obj.tag_funcs.draw != nil {
            if has_funcs do strings.write_rune(&name, ',')
            strings.write_string(&name, "draw")
            has_funcs = true
        }

        if obj.tag_funcs.stop != nil {
            if has_funcs do strings.write_rune(&name, ',')
            strings.write_string(&name, "stop")
            has_funcs = true
        }

        if !has_funcs do strings.write_string(&name, "none")

        ear.text(font, strings.to_string(name), 118, offy, colors[15])
        offy += charh

        redraw_thing()
        break
    }
}
