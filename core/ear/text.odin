package ear

import "../eau"

// just uses a basic system with a char table

text :: proc{
    text_rgba_wh,
    text_rgb_wh,
    text_gray_wh,
    text_rgba_size,
    text_rgb_size,
    text_gray_size,
    text_rgba,
    text_rgb,
    text_gray,

    text_rgba_wh_vec,
    text_rgb_wh_vec,
    text_gray_wh_vec,
    text_rgba_size_vec,
    text_rgb_size_vec,
    text_gray_size_vec,
    text_rgba_vec,
    text_rgb_vec,
    text_gray_vec,
}

text_rgba_wh :: proc(atlas: ^Texture, text: string, x, y: f32, w, h: f32, col: [4]f32) {
    ox, oy :f32= 0,0
    charw, charh := f32(atlas.width) / 16, f32(atlas.height) / 16

    for c in text {
        tex(
            atlas, 
            ox * charw * w + x,
            oy * charh * h + y,
            charw * w,
            charh * h,
            f32(u8(c) >> 4) * f32(charw),
            f32(u8(c) & 0xF) * f32(charh),
            f32(charw), f32(charh),
            col
        )

        ox += 1
        if c == '\t' do ox += 3
        if c == '\n' {
            ox = 0
            oy += 1
        }
    }
}

text_rgb_wh :: proc(atlas: ^Texture, text: string, x, y: f32, w, h: f32, col: [3]f32) { text_rgba_wh(atlas, text, x,y, w,h, eau.as_rgba(col)) }
text_gray_wh :: proc(atlas: ^Texture, text: string, x, y: f32, w, h: f32, col: f32) { text_rgb_wh(atlas, text, x,y, w,h, [3]f32 { col, col, col }) }
text_rgba_size :: proc(atlas: ^Texture, text: string, x, y: f32, size: f32, col: [4]f32) { text_rgba_wh(atlas, text, x,y, size,size, col) }
text_rgb_size :: proc(atlas: ^Texture, text: string, x, y: f32, size: f32, col: [3]f32) { text_rgb_wh(atlas, text, x,y, size,size, col) }
text_gray_size :: proc(atlas: ^Texture, text: string, x, y: f32, size: f32, col: f32) { text_gray_wh(atlas, text, x,y, size,size, col) }
text_rgba :: proc(atlas: ^Texture, text: string, x, y: f32, col: [4]f32) { text_rgba_size(atlas, text, x,y, 1, col) }
text_rgb :: proc(atlas: ^Texture, text: string, x, y: f32, col: [3]f32) { text_rgb_size(atlas, text, x,y, 1, col) }
text_gray :: proc(atlas: ^Texture, text: string, x, y: f32, col: f32) { text_gray_size(atlas, text, x,y, 1, col) }

text_rgba_wh_vec :: proc(atlas: ^Texture, text: string, pos: [2]f32, size: [2]f32, col: [4]f32) { text_rgba_wh(atlas, text, pos.x,pos.y, size.x,size.y, col) }
text_rgb_wh_vec :: proc(atlas: ^Texture, text: string, pos: [2]f32, size: [2]f32, col: [3]f32) { text_rgba_wh_vec(atlas, text, pos, size, eau.as_rgba(col)) }
text_gray_wh_vec :: proc(atlas: ^Texture, text: string, pos: [2]f32, size: [2]f32, col: f32) { text_rgb_wh_vec(atlas, text, pos, size, [3]f32 { col, col, col }) }
text_rgba_size_vec :: proc(atlas: ^Texture, text: string, pos: [2]f32, size: f32, col: [4]f32) { text_rgba_wh_vec(atlas, text, pos, {size,size}, col) }
text_rgb_size_vec :: proc(atlas: ^Texture, text: string, pos: [2]f32, size: f32, col: [3]f32) { text_rgb_wh_vec(atlas, text, pos, {size,size}, col) }
text_gray_size_vec :: proc(atlas: ^Texture, text: string, pos: [2]f32, size: f32, col: f32) { text_gray_wh_vec(atlas, text, pos, {size,size}, col) }
text_rgba_vec :: proc(atlas: ^Texture, text: string, pos: [2]f32, col: [4]f32) { text_rgba_size_vec(atlas, text, pos, 1, col) }
text_rgb_vec :: proc(atlas: ^Texture, text: string, pos: [2]f32, col: [3]f32) { text_rgb_size_vec(atlas, text, pos, 1, col) }
text_gray_vec :: proc(atlas: ^Texture, text: string, pos: [2]f32, col: f32) { text_gray_size_vec(atlas, text, pos, 1, col) }
