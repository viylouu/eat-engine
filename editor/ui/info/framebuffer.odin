package editor_ui_info

import "core:strings"

import "../../../core/ear"

import "../../_hook"

framebuffer :: proc(font: ^ear.Texture, obj: ^_hook.Object, name: ^strings.Builder, offy: f32, colors15: [3]f32, redraw_thing: proc()) {
    fb := (^ear.Framebuffer)(obj.data)
    offy := offy
    charh := f32(font.height)/16+1

    strings.write_string(name, "width:")
    strings.write_u64(name, u64(fb.desc.width))
    strings.write_string(name, ", height:")
    strings.write_u64(name, u64(fb.desc.height))

    ear.text(font, strings.to_string(name^), 118, offy, colors15)

    strings.builder_reset(name)

    for _,i in fb.desc.out_colors {
        col := fb.desc.out_colors[i]
        if col == nil do continue

        offy += charh
        strings.write_string(name, "- color tex ")
        strings.write_int(name, col^.idx)
        
        ear.text(font, strings.to_string(name^), 118, offy, colors15)

        strings.builder_reset(name)
    }
    
    if fb.desc.out_depth != nil {
        offy += charh
        strings.write_string(name, "- depth tex ")
        strings.write_int(name, fb.desc.out_depth.idx)

        ear.text(font, strings.to_string(name^), 118, offy, colors15)
    }

    redraw_thing()
}
