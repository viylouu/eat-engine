package eau

import "../../editor/_hook"

Arena :: struct{
    dests: [dynamic]^Destructor,
    
    idx: int,

    delete: proc(arena: ^Arena),
    add: proc(arena: ^Arena, data: rawptr, delete: proc(rawptr)) -> ^Destructor,
    clear: proc(arena: ^Arena),
}

Destructor :: struct {
    data: rawptr,
    delete: proc(rawptr),
}


create_arena :: proc() -> ^Arena {
    arena := new_clone(Arena{
        dests = make([dynamic]^Destructor),

        delete = delete_arena,
        add = add_to_arena,
        clear = clear_arena,
    })

    arena.idx = _hook.add_object({ type = .Arena, data = arena })
    return arena
}

delete_arena :: proc(arena: ^Arena) {
    arena->clear()
    delete(arena.dests)

    _hook.remove_object(arena.idx)
    free(arena)
}

add_to_arena :: proc(arena: ^Arena, data: rawptr, delete: proc(rawptr)) -> ^Destructor {
    dest := new_clone(Destructor{
        data = data,
        delete = delete,
    })
    append(&arena.dests, dest)
    return dest
}

clear_arena :: proc(arena: ^Arena) {
    for &dest in arena.dests do if dest != nil {
        if dest.data != nil do dest.delete(dest.data) 
        free(dest)
    }
    clear(&arena.dests)
}
