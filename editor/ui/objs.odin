package editor_ui

import "../../core/ear"
import "../../core/eau"
import "../../core/eaw"

import "../types"

obj_scroll: f32

objects :: proc(mx,my: f32, changed_sel: ^bool) {
    if eau.pointaabb({mx,my}, { { 0,0 }, { 114,360 }, .TopLeft, 0 }) do obj_scroll += eaw.mouse_scroll.y * 6
    if obj_scroll > 0 do obj_scroll = 0

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
        if offy + obj_scroll > charh + 2 {
            sel := eau.pointaabb({mx,my}, { { 2, offy + obj_scroll }, { 110, charh }, .TopLeft, 0 })

            ear.rect(2,offy + obj_scroll, 110,charh, sel || (selected == i && is_obj_selected)? colors[4] : colors[3])
            ear.rect(3,offy+1 + obj_scroll, 108,charh-2, sel || (selected == i && is_obj_selected)? colors[3] : colors[2])
            offy += 1

            if sel && eaw.is_mouse_pressed(.Left) {
                selected = i
                changed_sel^ = true
                is_obj_selected = true
            }
        } else do offy += 1

        offy += charh
        item = item.next
        i += 1

        if offy + obj_scroll > 360 do break
    }

    offy = charh + 4

    i = 0
    item = types.init_obj
    for item != nil {
        sel := eau.pointaabb({mx,my}, { { 2, offy }, { 110, charh }, .TopLeft, 0 })

        offy += 1
        if offy + obj_scroll > charh + 2 do ear.text(font, (^types.Object(rawptr))(item.obj).name, 4, offy + obj_scroll, colors[15])

        offy += charh
        item = item.next
        i += 1

        if offy + obj_scroll > 360 do break
    }
}
