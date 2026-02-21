package editor_ui

import "../../core/ear"
import "../../core/eau"
import "../../core/eaw"

import "../types"

objects :: proc(mx,my: f32, changed_sel: ^bool) {
    ear.rect(0,0, 114,360, colors[2])
    ear.rect(1,1, 112,358, colors[1])

    ear.text(font, "editor", 2,2, colors[15])

    charh := f32(font.height)/16+1
    offy := charh+2

    ear.rect(0,offy, 114,1, colors[2])
    offy += 2

    i := 0

    item: ^types.TypelessObj_LL = types.init_obj
    for item != nil {
        sel := eau.pointrect({mx,my}, { { 2, offy }, { 110, charh }, .TopLeft, 0 })

        ear.rect(2,offy, 110,charh, sel || (selected == i && is_obj_selected)? colors[4] : colors[3])
        ear.rect(3,offy+1, 108,charh-2, sel || (selected == i && is_obj_selected)? colors[3] : colors[2])
        offy += 1
        ear.text(font, (^types.Object(rawptr))(item.obj).name, 4, offy, colors[15])

        if sel && eaw.is_mouse_pressed(.Left) {
            selected = i
            changed_sel^ = true
            is_obj_selected = true
        }

        offy += charh
        item = item.next
        i += 1
    }
}
