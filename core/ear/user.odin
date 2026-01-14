package ear

clear :: proc{
    clear_rgba,
    clear_rgb,
}

clear_rgba :: proc(col: [4]f32) {
    
}

clear_rgb :: proc(col: [3]f32) { clear_rgba([4]f32 { col.r, col.g, col.b, 1 }) }
