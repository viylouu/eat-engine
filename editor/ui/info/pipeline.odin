package editor_ui_info

import "core:strings"

import "../../../core/ear"

import "../../_hook"

pipeline :: proc(font: ^ear.Texture, obj: ^_hook.Object, name: ^strings.Builder, offy: f32, colors15: [3]f32, redraw_thing: proc(), colors1: [3]f32) {
    pln := (^ear.Pipeline)(obj.data)
    offy := offy
    charh := f32(font.height)/16+1

    ear.text(font, pln.desc.depth? "depth:enabled" : "depth:disabled", 118,offy, colors15)

    offy += charh

    switch pln.desc.cull_mode {
    case .None: ear.text(font, "culling:none", 118, offy, colors15)
    case .Front: ear.text(font, "culling:front", 118, offy, colors15)
    case .Back: ear.text(font, "culling:back", 118, offy, colors15)
    }

    offy += charh

    if pln.desc.cull_mode != .None {
        switch pln.desc.front {
        case .CW: ear.text(font, "front:cw", 118, offy, colors15)
        case .CCW: ear.text(font, "front:ccw", 118, offy, colors15)
        }
        offy += charh
    }

    switch pln.desc.fill_mode {
    case .Fill: ear.text(font, "fill:fill", 118, offy, colors15)
    case .Line: ear.text(font, "fill:line", 118, offy, colors15)
    }

    offy += charh

    if blend, ok := pln.desc.blend.?; ok {
        blendfac_add :: proc(builder: ^strings.Builder, fac: ear.BlendFactor) {
            switch fac {
            case .Zero: strings.write_string(builder, "zero")
            case .One: strings.write_string(builder, "one")
            case .SrcColor: strings.write_string(builder, "src-color")
            case .InvSrcColor: strings.write_string(builder, "inv-src-color")
            case .DstColor: strings.write_string(builder, "dst-color")
            case .InvDstColor: strings.write_string(builder, "inv-dst-color")
            case .SrcAlpha: strings.write_string(builder, "src-alpha")
            case .InvSrcAlpha: strings.write_string(builder, "inv-src-alpha")
            case .DstAlpha: strings.write_string(builder, "dst-alpha")
            case .InvDstAlpha: strings.write_string(builder, "inv-dst-alpha")
            }
        }

        blendop_add :: proc(builder: ^strings.Builder, op: ear.BlendOp) {
            switch op {
            case .Add: strings.write_string(builder, "add")
            case .Subtract: strings.write_string(builder, "subtract")
            case .RevSubtract: strings.write_string(builder, "rev-subtract")
            case .Min: strings.write_string(builder, "min")
            case .Max: strings.write_string(builder, "max")
            }
        }

        add_thing :: proc(font: ^ear.Texture, builder: ^strings.Builder, name: string, offy: ^f32, charh: f32, thing: union{ ear.BlendFactor, ear.BlendOp }, colors15: [3]f32) {
            strings.builder_reset(builder)
            strings.write_string(builder, name)
            switch t in thing {
            case ear.BlendFactor: blendfac_add(builder, t)
            case ear.BlendOp: blendop_add(builder, t)
            }

            ear.text(font, strings.to_string(builder^), 118, offy^, colors15)
            offy^ += charh
        }

        ear.text(font, "blend state:", 118, offy, colors15)
        offy += charh

        add_thing(font, name, "- src-color:", &offy, charh, blend.src_color, colors15)
        add_thing(font, name, "- dst-color:", &offy, charh, blend.dst_color, colors15)
        add_thing(font, name, "- color-op:", &offy, charh, blend.color_op, colors15)
        add_thing(font, name, "- src-alpha:", &offy, charh, blend.src_alpha, colors15)
        add_thing(font, name, "- dst-alpha:", &offy, charh, blend.dst_alpha, colors15)
        add_thing(font, name, "- alpha-op:", &offy, charh, blend.alpha_op, colors15)

        offy -= charh
    } else do ear.text(font, "blending disabled", 118, offy, colors15)

    offy += charh

    if len(pln.desc.vertex_attribs) == 0 do ear.text(font, "no vertex attribs", 118, offy, colors15)
    else {
        ear.text(font, "vertex attribs:", 118, offy, colors15)

        offy += charh

        for attrib in pln.desc.vertex_attribs {
            strings.builder_reset(name)
            strings.write_string(name, " - loc:")
            strings.write_u64(name, u64(attrib.location))
            strings.write_string(name, ", type:")
            type_s: string
            switch attrib.type {
            case .Float: type_s = "float"
            case .Int: type_s = "int"
            }
            strings.write_string(name, type_s)
            strings.write_string(name, ", comps:")
            strings.write_u64(name, u64(attrib.components))
            if attrib.type != .Int {
                strings.write_string(name, ", norm:")
                strings.write_string(name, attrib.norm? "true" : "false")
            }
            strings.write_string(name, ", off:")
            strings.write_u64(name, u64(attrib.offset))
            strings.write_string(name, ", slot:")
            strings.write_u64(name, u64(attrib.slot))

            sname := strings.to_string(name^)
            text_width := f32(len(sname)) * f32(font.width)/16
            ear.rect(118, offy, text_width, f32(font.height)/16, colors1)
            ear.text(font, sname, 118, offy, colors15)

            offy += charh
        }
    }

    redraw_thing()
}
