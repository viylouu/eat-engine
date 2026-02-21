package editor_ui_info

import "core:strings"

import "../../../core/ear"
import "../../../core/eaw"

import "../../_hook"

texture :: proc(font: ^ear.Texture, obj: ^_hook.Object, name: ^strings.Builder, offy: f32, colors15: [3]f32, redraw_thing: proc()) {
    tex := (^ear.Texture)(obj.data)
    offy := offy
    charh := f32(font.height)/16+1

    strings.write_string(name, "width:")
    strings.write_u64(name, u64(tex.width))
    strings.write_string(name, ", height:")
    strings.write_u64(name, u64(tex.height))

    ear.text(font, strings.to_string(name^), 118, offy, colors15)
    
    offy += charh

    switch tex.desc.type {
    case .Color: ear.text(font, "type:color", 118, offy, colors15)
    case .Depth: ear.text(font, "type:depth", 118, offy, colors15)
    case .Hdr: ear.text(font, "type:hdr", 118, offy, colors15)
    case .Hdr32: ear.text(font, "type:hdr32", 118, offy, colors15)
    }

    offy += charh

    height := 127-offy
    ear.rect(118, offy, 124,height, 0)

    redraw_thing()
    ear.bind_framebuffer(nil)
   
    ear.tex(tex, 118./640.*f32(eaw.width), offy/360.*f32(eaw.height), 124/640.*f32(eaw.width),height/360.*f32(eaw.height), colors15)
}
