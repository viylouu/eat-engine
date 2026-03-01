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

pointaabb :: proc(p: [2]f32, r: Rectangle) -> bool {
    a := CONV_rect_topleftify(r)
    return p.x < a.pos.x + a.size.x &&
           p.x > a.pos.x &&
           p.y < a.pos.y + a.size.y &&
           p.y > a.pos.y
}

aabb3d :: proc(min1, max1, min2, max2: [3]f32) -> bool {
    return min1.x < max2.x &&
           max1.x > min2.x &&
           min1.y < max2.y &&
           max1.y > min2.y &&
           min1.z < max2.z &&
           max1.z > min2.z
}

gjk3d :: proc(hull1: [][3]f32, hull2: [][3]f32) -> bool {
    res, simp := gjk3d_simplex(hull1, hull2)
    if res do delete(simp)
    return res
}

@private
really_big : f32 : 340282346638528859811704183484516925440

// credit to winterdev on the article for this
// - https://winter.dev/articles/gjk-algorithm
// also, simplex must be deleted
gjk3d_simplex :: proc(hull1: [][3]f32, hull2: [][3]f32) -> (res: bool, simplex: [dynamic][3]f32) {
    furthest :: proc(hull: [][3]f32, dir: [3]f32) -> (max: [3]f32) {
        maxdist: f32 = -really_big
        
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

    for i in 0..<4 {
        dir = linalg.normalize(dir)
        supp = support(hull1, hull2, dir)

        if linalg.dot(supp, dir) <= 0 do return false, nil

        inject_at(&simplex, 0, supp)

        if next_simplex(&simplex, &dir) do return true, simplex
    }

    return false, nil
}

CollisionInfo :: struct{
    norm: [3]f32,
    depth: f32
}

@private
Edge :: struct{ a,b: int }

// credit to winterdev on the article for this
// - https://winter.dev/articles/epa-algorithm
epa3d :: proc(simplex: [dynamic][3]f32, hull1: [][3]f32, hull2: [][3]f32) -> CollisionInfo {
    get_face_normals :: proc(polytope: [dynamic][3]f32, faces: [dynamic]int) -> ([dynamic][4]f32, int) {
        norms := make([dynamic][4]f32)
        mintri: int
        mindist := really_big

        for i := 0; i < len(faces); i += 3 {
            a, b, c := polytope[faces[i+0]], 
                       polytope[faces[i+1]], 
                       polytope[faces[i+2]]

            norm := linalg.normalize(linalg.cross(b - a, c - a))
            dist := linalg.dot(norm, a)

            if dist < 0 {
                norm = -norm
                dist = -dist
            }

            append(&norms, [4]f32{ norm.x, norm.y, norm.z, dist })

            if dist < mindist {
                mintri = i / 3
                mindist = dist
            }
        }

        return norms, mintri
    }

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

    same_dir :: proc(dir, ao: [3]f32) -> bool {
        return linalg.dot(dir, ao) > 0
    }

    add_if_unique_edge :: proc(edges: ^[dynamic]Edge, faces: [dynamic]int, a,b: int) {
        rev_ind := -1
        for edge, i in edges do if edge.a == faces[b] && edge.b == faces[a] {
            rev_ind = i
            break
        }

        if rev_ind != -1 do ordered_remove(edges, rev_ind)
        else do append(edges, Edge{ faces[a], faces[b] })
    }

    polytope := make([dynamic][3]f32, len(simplex))
    copy(polytope[:], simplex[:])
    defer delete(polytope)

    faces := [dynamic]int{
        0, 1, 2,
        0, 3, 1,
        0, 2, 3,
        1, 3, 2,
    }
    defer delete(faces)

    normals, minface := get_face_normals(polytope, faces)
    defer delete(normals)

    minnorm: [3]f32
    mindist := really_big

    for i := 0; mindist == really_big && i < 1024; i+= 1 {
        minnorm = normals[minface].xyz
        mindist = normals[minface].w

        supp := support(hull1, hull2, minnorm)
        sdist := linalg.dot(minnorm, supp)

        if math.abs(sdist - mindist) > .001 {
            mindist = really_big

            unique := make([dynamic]Edge)
            for i := 0; i < len(normals); i += 1 do if linalg.dot(normals[i].xyz, supp) > linalg.dot(normals[i].xyz, polytope[faces[i*3]]) {
                f := i * 3
                add_if_unique_edge(&unique, faces, f,   f+1)
                add_if_unique_edge(&unique, faces, f+1, f+2)
                add_if_unique_edge(&unique, faces, f+2, f)

                faces[f+2] = faces[len(faces)-1]
                pop(&faces)
                faces[f+1] = faces[len(faces)-1]
                pop(&faces)
                faces[f] = faces[len(faces)-1]
                pop(&faces)

                normals[i] = normals[len(normals)-1]
                pop(&normals)

                i -= 1
            }

            new_faces := make([dynamic]int)
            defer delete(new_faces)
            for edge in unique {
                append(&new_faces, edge.a)
                append(&new_faces, edge.b)
                append(&new_faces, len(polytope))
            }

            append(&polytope, supp)

            new_normals, new_minface := get_face_normals(polytope, new_faces)
            defer delete(new_normals)

            old_mindist := really_big
            for norm, i in normals do if norm.w < old_mindist {
                old_mindist = norm.w
                minface = i
            }

            if new_normals[new_minface].w < old_mindist do minface = new_minface + len(normals)

            for face in new_faces do append(&faces, face)
            for norm in new_normals do append(&normals, norm)
        }
    }

    return CollisionInfo{
        norm = minnorm,
        depth = mindist
    }
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
