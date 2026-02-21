package editor_ui_info

import "core:strings"

import "../../../core/ear"

import "../../_hook"

buffer :: proc(font: ^ear.Texture, obj: ^_hook.Object, name: ^strings.Builder, offy: f32, colors15: [3]f32, redraw_thing: proc()) {
    buf := (^ear.Buffer)(obj.data)
    offy := offy
    charh := f32(font.height)/16+1

    type: string
    switch buf.desc.type {
    case .Vertex: type = "type:vertex"
    case .Uniform: type = "type:uniform"
    case .Storage: type = "type:storage"
    case .Index: type = "type:index"
    }
    ear.text(font, type, 118, offy, colors15)

    offy += charh

    switch buf.desc.usage {
    case .Dynamic: ear.text(font, "usage:dynamic", 118, offy, colors15)
    case .Static: ear.text(font, "usage:static", 118, offy, colors15)
    }

    offy += charh

    strings.builder_reset(name)
    strings.write_string(name, "elements:")
    strings.write_u64(name, u64(buf.size/buf.desc.stride))

    ear.text(font, strings.to_string(name^), 118, offy, colors15)

    offy += charh

    strings.builder_reset(name)
    strings.write_string(name, "stride:")
    strings.write_u64(name, u64(buf.desc.stride))

    ear.text(font, strings.to_string(name^), 118, offy, colors15)

    redraw_thing()
}
