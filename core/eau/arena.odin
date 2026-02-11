package eau

// this is the LEAST safe code i have EVER written
// HOW DOES THIS WORK CORRECTLY????
// before you use this (using the add function) READ THE CODE

Arena :: struct{
    objs: [dynamic]Object,

    delete: proc(arena: ^Arena),
    add: proc(arena: ^Arena, data: rawptr, delete: rawptr),
}

Object :: struct {
    data: ^any,
    delete: proc(^any),
}

create_arena :: proc() -> ^Arena {
    arena := new_clone(Arena{
        objs = make([dynamic]Object),

        delete = delete_arena,
        add = add_to_arena,
    })

    return arena
}

delete_arena :: proc(arena: ^Arena) {
    for &obj in arena.objs do obj.delete(obj.data)
    delete(arena.objs)

    free(arena)
}

add_to_arena :: proc(arena: ^Arena, data: rawptr, delete: rawptr) {
    append(&arena.objs, Object{
        data = (^any)(data),
        delete = proc(^any)(delete),
    })
}
