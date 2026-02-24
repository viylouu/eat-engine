package editor_ui

import "core:strings"

import "../../core/ear"
import "../../core/eau"
import "../../core/eaw"

import "../_hook"

type_scroll: f32

types :: proc(mx,my: f32, changed_sel: ^bool) {
    if eau.pointaabb({mx,my}, { { 114,360-90 }, { 640-64,94 }, .TopLeft, 0 }) do type_scroll += eaw.mouse_scroll.y * 6
    if type_scroll > 0 do type_scroll = 0

    ear.rect(114,360-94, 640-64,94, colors[2])
    ear.rect(115,361-94, 638-64,92, colors[1])

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

        if f32(y)+363-94 + type_scroll > 360-94 {
            sel := eau.pointaabb({mx,my}, { { f32(x)+117 - f32(text_width)-3, f32(y)+363-95 + type_scroll }, { f32(text_width)+1, f32(font.height)/16+1 }, .TopLeft, 0 })

            ear.rect(f32(x)+117 - f32(text_width)-3, f32(y)+363-95 + type_scroll, f32(text_width)+1, f32(font.height)/16+1, sel || (selected == i && !is_obj_selected)? colors[4] : colors[3])
            ear.rect(f32(x)+117 - f32(text_width)-2, f32(y)+363-94 + type_scroll, f32(text_width)-1, f32(font.height)/16-1, sel || (selected == i && !is_obj_selected)? colors[3] : colors[2])

            if sel && eaw.is_mouse_pressed(.Left) {
                selected = i
                changed_sel^ = true
                is_obj_selected = false
            }
        }

        if f32(y)+363-94 + type_scroll > 360 do break
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

        if f32(y)+363-94 + type_scroll > 360-94 do ear.text(font, sname, f32(x)+117 - f32(text_width)-2,f32(y)+363-94 + type_scroll, 1, colors[15])

        strings.builder_destroy(name)

        if f32(y)+363-94 + type_scroll > 360 do break
    }
}
