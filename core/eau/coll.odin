package eau

Alignment :: enum{
    TopLeft, TopCenter, TopRight,
    MidLeft, MidCenter, MidRight,
    BotLeft, BotCenter, BotRight,
}

Rectangle :: struct{
    pos: [2]f32,
    size: [2]f32,
    align: Alignment,
    rot: f32,
}

aabb2d :: proc(a: Rectangle, b: Rectangle) -> bool {
    a_tl, b_tl := CONV_rect_topleftify(a),
                  CONV_rect_topleftify(b)
    return a_tl.pos.x < b_tl.pos.x + b_tl.size.x &&
           a_tl.pos.x + a_tl.size.x > b_tl.pos.x &&
           a_tl.pos.y < b_tl.pos.y + b_tl.size.y &&
           a_tl.pos.y + a_tl.size.y > b_tl.pos.y
}



@private
CONV_rect_topleftify :: proc(rect: Rectangle) -> Rectangle {
    off: [2]f32

    switch (rect.align) {
    case .TopLeft:   off = { 0, 0 }
    case .TopCenter: off = { .5, 0 }
    case .TopRight:  off = { 1, 0 }
    case .MidLeft:   off = { 0, .5 }
    case .MidCenter: off = { .5, .5 }
    case .MidRight:  off = { 1, .5 }
    case .BotLeft:   off = { 0, 1 }
    case .BotCenter: off = { .5, 1 }
    case .BotRight:  off = { 1, 1 }
    }

    return Rectangle{
        pos = rect.pos - off * rect.size,
        size = rect.size,
        align = .TopLeft,
        rot = 0,
    }
}
