#+feature dynamic-literals
package eau

import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"

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

gjk3d :: proc(hull1: [][3]f32, hull2: [][3]f32) -> bool {
    res, simp := gjk3d_simplex(hull1, hull2)
    if res do delete(simp)
    return res
}

// credit to winterdev on the article for this
// - https://winter.dev/articles/gjk-algorithm
// also, simplex must be deleted
gjk3d_simplex :: proc(hull1: [][3]f32, hull2: [][3]f32) -> (res: bool, simplex: [dynamic][3]f32) {
    furthest :: proc(hull: [][3]f32, dir: [3]f32) -> (max: [3]f32) {
        maxdist: f32 = -340282346638528859811704183484516925440 // source: trust me bro
        
        for vert in hull {
            dist := linalg.dot(vert, dir)
            if dist > maxdist {
                maxdist = dist
                max = vert
            }
        }

        return max
    }

    support :: proc(hull1: [][3]f32, hull2: [][3]f32, dir: [3]f32) -> [3]f32 {
        return furthest(hull1, dir) - furthest(hull2, -dir)
    }

    next_simplex :: proc(points: ^[dynamic][3]f32, dir: ^[3]f32) -> bool {
        same_dir :: proc(dir, ao: [3]f32) -> bool {
            return linalg.dot(dir, ao) > 0
        }

        line :: proc(points: ^[dynamic][3]f32, dir: ^[3]f32) -> bool {
            a, b := points[0], points[1]

            ab, ao := b - a,
                      0 - a

            if same_dir(ab, ao) do dir^ = linalg.cross(linalg.cross(ab, ao), ab)
            else {
                points^ = { a }
                dir^ = ao
            }

            return false
        }
        tri :: proc(points: ^[dynamic][3]f32, dir: ^[3]f32) -> bool {
            a, b, c := points[0], points[1], points[2]

            ab, ac, ao := b - a,
                          c - a,
                          0 - a

            abc := linalg.cross(ab, ac)

            if same_dir(linalg.cross(abc, ac), ao) {
                if same_dir(ac, ao) {
                    points^ = { a, c }
                    dir^ = linalg.cross(linalg.cross(ac, ao), ac)
                } else {
                    points^ = { a, b }
                    return line(points, dir)
                }
            } else {
                if same_dir(linalg.cross(ab, abc), ao) {
                    points^ = { a, b }
                    return line(points, dir)
                } else {
                    if same_dir(abc, ao) do dir^ = abc
                    else {
                        points^ = { a, c, b }
                        dir^ = -abc
                    }
                }
            }

            return false
        }
        tetra :: proc(points: ^[dynamic][3]f32, dir: ^[3]f32) -> bool {
            a, b, c, d := points[0], points[1], points[2], points[3]

            ab, ac, ad, ao := b - a,
                              c - a,
                              d - a,
                              0 - a

            abc, acd, adb := linalg.cross(ab, ac),
                             linalg.cross(ac, ad),
                             linalg.cross(ad, ab)

            if same_dir(abc, ao) {
                points^ = { a, b, c }
                return tri(points, dir)
            } if same_dir(acd, ao) {
                points^ = { a, c, d }
                return tri(points, dir)
            } if same_dir(adb, ao) {
                points^ = { a, d, b }
                return tri(points, dir)
            }

            return true
        }

        switch len(points) {
        case 2: return line(points, dir)
        case 3: return tri(points, dir)
        case 4: return tetra(points, dir)
        }

        assert(false)
        return false
    }

    supp := support(hull1, hull2, { 1,0,0 })

    simplex = make([dynamic][3]f32)
    append(&simplex, supp)

    dir := -supp

    for i in 0..<64 {
        dir = linalg.normalize(dir)
        supp = support(hull1, hull2, dir)

        if linalg.dot(supp, dir) <= 0 do return false, nil

        inject_at(&simplex, 0, supp)

        if next_simplex(&simplex, &dir) do return true, simplex
    }

    return false, nil
}


@private
CONV_rect_topleftify :: proc(rect: Rectangle) -> Rectangle {
    off: [2]f32

    switch rect.align {
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
