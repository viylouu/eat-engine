package editor_ui_info

import "../../../core/ear"

none :: proc(font: ^ear.Texture, offy: f32, colors15: [3]f32, redraw_thing: proc()) {
    ear.text(font, "...what? this object is removed. how are you seeing this?", 118, offy, colors15)
    redraw_thing()
}
