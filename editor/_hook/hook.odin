package _hook

// this is NOT something the user should use
// this is SPECIFICALLY designed to work with engine tech
// you *may* use this however IF you need to add custom objects, and youre editing the editor and whatever
// but otherwise, this is not designed for users

// this would be a union, however, i need the things to be able to import this, and not the other way around
objects: [dynamic]Object
Object :: struct{
    type: Type,
    data: rawptr,
}

Type :: enum {
    Buffer,
    Framebuffer,
    Pipeline,
    TexArray,
    Texture,
    Arena,
}

add_object :: proc(obj: Object) -> int {
    append(&objects, obj)
    return len(objects)-1
}

remove_object :: proc(idx: int) {
    if idx < 0 do return
    objects[idx].data = nil
}


init :: proc() {
    objects = make([dynamic]Object)
}

stop :: proc() {
    delete(objects)
}
