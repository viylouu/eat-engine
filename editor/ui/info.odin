package editor_ui

import "core:strings"

import "../../core/ear"
import "../../core/eau"
import "../../core/eaw"

import "../_hook"
import "info"

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
    
}
