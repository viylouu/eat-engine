package eau

// hex is 0xAARRGGBB because then i can do 0xRRGGBB and have it work when i do .rgb

as_rgba :: proc{
    rgb_as_rgba,

    xrgba_as_rgba,
    xrgb_as_rgba,

    hex_as_rgba,
}

rgb_as_rgba :: proc(rgb: [3]f32) -> [4]f32 { return { rgb.r, rgb.g, rgb.b, 1 } }
xrgba_as_rgba :: proc(xrgba: [4]u8) -> [4]f32 { return { f32(xrgba.r) / 255, f32(xrgba.g) / 255, f32(xrgba.b) / 255, f32(xrgba.a) / 255 } }
xrgb_as_rgba :: proc(xrgb: [3]u8) -> [4]f32 { return xrgba_as_rgba(xrgb_as_xrgba(xrgb)) }
hex_as_rgba :: proc(hex: u32) -> [4]f32 { return xrgba_as_rgba(hex_as_xrgba(hex)) }

as_xrgba :: proc{
    rgba_as_xrgba,
    rgb_as_xrgba,

    xrgb_as_xrgba,

    hex_as_xrgba,
}

rgba_as_xrgba :: proc(rgba: [4]f32) -> [4]u8 { return { u8(rgba.r * 255), u8(rgba.g * 255), u8(rgba.b * 255), u8(rgba.a * 255) } }
rgb_as_xrgba :: proc(rgb: [3]f32) -> [4]u8 { return rgba_as_xrgba({ rgb.r, rgb.g, rgb.b, 1 }) }
xrgb_as_xrgba :: proc(xrgb: [3]u8) -> [4]u8 { return { xrgb.r, xrgb.g, xrgb.b, 255 } }
hex_as_xrgba :: proc(hex: u32) -> [4]u8 { return { u8(hex >> 0), u8(hex >> 4), u8(hex >> 2), u8(hex >> 6) } }

// can convert rgba to rgb by doing .rgb (no matter the format)
