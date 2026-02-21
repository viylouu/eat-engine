package editor_ui_info

import "core:strings"

import "../../../core/ear"
import "../../../core/eau"

import "../../_hook"

arena :: proc(font: ^ear.Texture, obj: ^_hook.Object, name: ^strings.Builder, offy: f32, colors15: [3]f32, redraw_thing: proc()) {
    arena := (^eau.Arena)(obj.data)

    strings.write_string(name, "objects:")
    strings.write_int(name, len(arena.dests))

    ear.text(font, strings.to_string(name^), 118, offy, colors15)

    redraw_thing()
}
