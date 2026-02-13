package eau

Object :: struct{
    pos: [3]f32,
    size: [3]f32,
    rot: [3]f32,

    desc: ObjectDesc,
    dest: ^^Destructor,
    data: rawptr,

    delete: proc(obj: ^Object),
    init: proc(obj: ^Object),
    frame: proc(obj: ^Object),
}

ObjectDesc :: struct{
    init: Maybe(proc(obj: ^Object)),
    frame: Maybe(proc(obj: ^Object)),
    delete: Maybe(proc(obj: ^Object)),
}


// if this (the data param) is confusing, heres why:
// data needs to be a struct with `using [NAME]: ^Object` in it
// and then it has other data, and you reference it in the param
// this is for ease of user use
create_object :: proc(desc: ObjectDesc, data: ^^Object, arena: ^Arena = nil) -> ^Object {
    obj := new_clone(Object{
        desc = desc,
        data = data,

        delete = delete_object,
        init = init_object,
        frame = frame_object,
    })

    data^ = obj

    if arena != nil do obj.dest = arena->add(obj, proc(p: rawptr){ delete_object((^Object)(p)) })
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

