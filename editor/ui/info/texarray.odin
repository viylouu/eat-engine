package editor_ui_info

import "core:strings"

import "../../../core/ear"

import "../../_hook"

texarray :: proc(font: ^ear.Texture, obj: ^_hook.Object, name: ^strings.Builder, offy: f32, colors15: [3]f32, redraw_thing: proc()) {
    arr := (^ear.TexArray)(obj.data)
    offy := offy
    charh := f32(font.height)/16+1

    strings.write_string(name, "layers:")
    strings.write_u64(name, u64(arr.desc.layers))

    ear.text(font, strings.to_string(name^), 118, offy, colors15)

    offy += charh

    strings.builder_reset(name)
    strings.write_string(name, "width:")
    strings.write_u64(name, u64(arr.desc.width))
    strings.write_string(name, ", height:")
    strings.write_u64(name, u64(arr.desc.height))

    ear.text(font, strings.to_string(name^), 118, offy, colors15)

    offy += charh

    switch arr.desc.type {
    case .Color: ear.text(font, "type:color", 118, offy, colors15)
    case .Depth: ear.text(font, "type:depth", 118, offy, colors15)
    case .Hdr: ear.text(font, "type:hdr", 118, offy, colors15)
    case .Hdr32: ear.text(font, "type:hdr32", 118, offy, colors15)
    }

    offy += charh

    switch arr.desc.filter {
    case .Nearest: ear.text(font, "filter:nearest", 118, offy, colors15)
    case .Linear: ear.text(font, "filter:linear", 118, offy, colors15)
    }

    offy += charh

    ear.text(font, "textures:", 118, offy, colors15)

    offy += charh

    for tex in arr.texs {
        if tex == nil {
            ear.text(font, "- nil", 118, offy, colors15)
        } else {
            strings.builder_reset(name)
            strings.write_string(name, "- texture ")
            strings.write_u64(name, u64(tex.idx))
            ear.text(font, strings.to_string(name^), 118, offy, colors15)
        }

        offy += charh
    }

    redraw_thing()
}
