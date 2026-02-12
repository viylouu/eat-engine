package eau

// this is the LEAST safe code i have EVER written
// HOW DOES THIS WORK CORRECTLY????
// before you use this (using the add function) READ THE CODE

Arena :: struct{
    dests: [dynamic]^Destructor,

    delete: proc(arena: ^Arena),
    add: proc(arena: ^Arena, data: rawptr, delete: rawptr) -> ^^Destructor,
}

Destructor :: struct {
    data: ^any,
    delete: proc(^any),
}


create_arena :: proc() -> ^Arena {
    arena := new_clone(Arena{
        dests = make([dynamic]^Destructor),

        delete = delete_arena,
        add = add_to_arena,
    })

    return arena
}

delete_arena :: proc(arena: ^Arena) {
    for &dest in arena.dests do if dest != nil { 
        dest.delete(dest.data) 
        //free(dest) // this is done by delete (or else the function is WRONG)
    }
    delete(arena.dests)

    free(arena)
}

add_to_arena :: proc(arena: ^Arena, data: rawptr, delete: rawptr) -> ^^Destructor {
    dest := new_clone(Destructor{
        data = (^any)(data),
        delete = proc(^any)(delete),
    })
    append(&arena.dests, dest)
    return &arena.dests[len(arena.dests)-1] // holy shit
}
