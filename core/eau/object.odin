package eau

Object :: struct{
    pos: [3]f32,
    size: [3]f32,
    rot: [3]f32,

    desc: ObjectDesc,
    dest: ^^Destructor,

    delete: proc(obj: ^Object),
    init: proc(obj: ^Object),
    frame: proc(obj: ^Object),
}

ObjectDesc :: struct{
    init: Maybe(proc(obj: ^Object)),
    frame: Maybe(proc(obj: ^Object)),
    delete: Maybe(proc(obj: ^Object)),
}


create_object :: proc(desc: ObjectDesc, arena: ^Arena = nil) -> ^Object {
    obj := new_clone(Object{
        desc = desc,

        delete = delete_object,
    })

    if arena != nil do obj.dest = arena->add(obj, rawptr(delete_object))
    return obj
}

delete_object :: proc(obj: ^Object) {
    if delete,ok := obj.desc.delete.?; ok do delete(obj)

    if obj.dest != nil { free(obj.dest^); obj.dest^ = nil }
    free(obj)
}

init_object :: proc(obj: ^Object) {
    if init,ok := obj.desc.init.?; ok do init(obj)
}

frame_object :: proc(obj: ^Object) {
    if frame,ok := obj.desc.frame.?; ok do frame(obj)
}
