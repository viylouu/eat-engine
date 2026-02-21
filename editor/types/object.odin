package editor_types

import "core:fmt"

import "../../core/eau"

import "base:runtime"

TypelessObj_LL :: struct{ obj: rawptr, t: typeid, prev: ^TypelessObj_LL, next: ^TypelessObj_LL }
init_obj: ^TypelessObj_LL
end_obj: ^TypelessObj_LL


Object :: struct($T: typeid) {
    name: string,
    data: ^T,

    tobj: TypelessObj_LL,
    dest: ^eau.Destructor,

    delete: proc(obj: ^Object(T)),

    pos: [3]f32,
    rot: [3]f32,

    tag_funcs: struct{
        init: Maybe(proc(rawptr)),
        update: Maybe(proc(rawptr)),
        draw: Maybe(proc(rawptr)),
        stop: Maybe(proc(rawptr)),
    },
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

    info := runtime.type_info_base(type_info_of(T))

    #partial switch str in info.variant {
    case: // do nothing
    case runtime.Type_Info_Struct:
        for i in 0..<str.field_count do switch str.tags[i] {
        case "init", "draw", "update", "stop": #partial switch func in str.types[i].variant {
            case: assert(false)
            case runtime.Type_Info_Procedure:
                func_ptr := (^rawptr)(uintptr(obj.data) + str.offsets[i])
                fn := transmute(proc(rawptr))(func_ptr^)
                switch str.tags[i] {
                case "init":   obj.tag_funcs.init   = fn
                case "draw":   obj.tag_funcs.draw   = fn
                case "update": obj.tag_funcs.update = fn
                case "stop":   obj.tag_funcs.stop   = fn
                }
            }
        }
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


wrap_object_proc :: proc($p: proc(^Object($T))) -> proc(rawptr) {
    return proc(obj: rawptr) { p((^Object(T))(obj)) }
}


init_objects :: proc() {
    item: ^TypelessObj_LL = init_obj
    for item != nil {
        if init, ok := (^Object(any))(item.obj).tag_funcs.init.?; ok do init(item.obj)
        item = item.next
    }
}

draw_objects :: proc() {
    item: ^TypelessObj_LL = init_obj
    for item != nil {
        if draw, ok := (^Object(any))(item.obj).tag_funcs.draw.?; ok do draw(item.obj)
        item = item.next
    }
}

update_objects :: proc() {
    item: ^TypelessObj_LL = init_obj
    for item != nil {
        if update, ok := (^Object(any))(item.obj).tag_funcs.update.?; ok do update(item.obj)
        item = item.next
    }
}

stop_objects :: proc() {
    item: ^TypelessObj_LL = init_obj
    for item != nil {
        if stop, ok := (^Object(any))(item.obj).tag_funcs.stop.?; ok do stop(item.obj)
        item = item.next
    }
}
