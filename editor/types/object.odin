package editor_types

import "../../core/eau"

TypelessObj_LL :: struct{ obj: rawptr, t: typeid, prev: ^TypelessObj_LL, next: ^TypelessObj_LL }
init_obj: ^TypelessObj_LL
end_obj: ^TypelessObj_LL


Object :: struct($T: typeid) {
    name: string,
    data: ^T,

    tobj: TypelessObj_LL,
    dest: ^eau.Destructor,

    delete: proc(obj: ^Object(T)),
}


create_object :: proc{
    _create_object_all,
    _create_object_name,
    _create_object_arena,
    _create_object_none,
}

_create_object_all :: proc(data: $T, name: string, arena: ^eau.Arena) -> ^Object(T) {
    obj := new_clone(Object(T){
        name = name,
        data = new_clone(data),

        delete = proc(obj: ^Object(T)) { delete_object(obj) },
    })

    if arena != nil do obj.dest = arena->add(obj, proc(p: rawptr){ delete_object((^Object(T))(p)) })

    obj.tobj = { obj, T, nil,nil }
    if init_obj == nil {
        init_obj = &obj.tobj
        end_obj = &obj.tobj
    } else {
        end_obj.next = &obj.tobj
        obj.tobj.prev = end_obj
        end_obj = &obj.tobj
    }

    return obj
}

_create_object_name :: proc(data: $T, name: string) -> ^Object(T) { return _create_object_all(data, name, nil) }
_create_object_arena :: proc(data: $T, arena: ^eau.Arena) -> ^Object(T) { return _create_object_all(data, "Object", arena) }
_create_object_none :: proc(data: $T) -> ^Object(T) { return _create_object_arena(data, nil) }

delete_object :: proc(obj: ^Object($T)) {
    free(obj.data)

    if obj.tobj.next != nil {
        if obj.tobj.prev != nil do obj.tobj.next.prev = obj.tobj.prev
        else do obj.tobj.next.prev = nil
    } else if obj.tobj.prev != nil do obj.tobj.prev.next = nil

    if init_obj.obj == obj {
        if obj.tobj.next != nil do init_obj = obj.tobj.next
        else do init_obj = nil
    }

    if end_obj.obj == obj {
        if obj.tobj.prev != nil do end_obj = obj.tobj.prev
        else do end_obj = nil
    }

    if obj.dest != nil do obj.dest.data = nil
    free(obj)
}
