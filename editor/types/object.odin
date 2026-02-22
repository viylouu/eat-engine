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

    pos3d: ^[3]f32, rot3d: ^[3]f32,
    pos2d: ^[2]f32, rot2d: ^f32,
    pos3d64: ^[3]f64, rot3d64: ^[3]f64,
    pos2d64: ^[2]f64, rot2d64: ^f64,

    tag_funcs: struct{
        init: /*proc(rawptr)*/^ObjectProc,
        update: /*proc(rawptr)*/^ObjectProc,
        draw: /*proc(rawptr)*/^ObjectProc,
        stop: /*proc(rawptr)*/^ObjectProc,
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
        case "init", "draw", "update", "stop": 
            obj_func := str.types[i]
            #partial switch func in obj_func.variant {
            case: assert(type_of(obj_func.variant) == runtime.Type_Info_Named)
            case runtime.Type_Info_Named:
                assert(func.name == "ObjectProc")

                ptr := (^ObjectProc)(uintptr(obj.data) + str.offsets[i])
                
                switch str.tags[i] {
                case "init":   obj.tag_funcs.init = ptr
                case "draw":   obj.tag_funcs.draw = ptr
                case "update": obj.tag_funcs.update = ptr
                case "stop":   obj.tag_funcs.stop = ptr
                }
            }
        case "position": 
            pos_arr := str.types[i]
            #partial switch pos in pos_arr.variant {
            case: assert(type_of(pos_arr.variant) == runtime.Type_Info_Array)
            case runtime.Type_Info_Array:
                pos_ptr := (^rawptr)(uintptr(obj.data) + str.offsets[i])

                switch pos.count {
                case: assert(pos.count == 2 || pos.count == 3)
                case 2:
                    if pos.elem_size == size_of(f32) do obj.pos2d = (^[2]f32)(pos_ptr)
                    else if pos.elem_size == size_of(f64) do obj.pos2d64 = (^[2]f64)(pos_ptr)
                    else do assert(pos.elem_size == size_of(f32) || pos.elem_size == size_of(f64))
                case 3:
                    if pos.elem_size == size_of(f32) do obj.pos3d = (^[3]f32)(pos_ptr)
                    else if pos.elem_size == size_of(f64) do obj.pos3d64 = (^[3]f64)(pos_ptr)
                    else do assert(pos.elem_size == size_of(f32) || pos.elem_size == size_of(f64))
                }
            }
        case "rotation": 
            rot_arr := str.types[i]
            #partial switch rot in rot_arr.variant {
            case: assert(type_of(rot_arr.variant) == runtime.Type_Info_Array || type_of(rot_arr.variant) == runtime.Type_Info_Float)
            case runtime.Type_Info_Array:
                rot_ptr := (^rawptr)(uintptr(obj.data) + str.offsets[i])

                switch rot.count {
                case: assert(rot.count == 3)
                case 3:
                    if rot.elem_size == size_of(f32) do obj.rot3d = (^[3]f32)(rot_ptr)
                    else if rot.elem_size == size_of(f64) do obj.rot3d64 = (^[3]f64)(rot_ptr)
                    else do assert(rot.elem_size == size_of(f32) || rot.elem_size == size_of(f64))
                }
            case runtime.Type_Info_Float:
                rot_ptr := (^rawptr)(uintptr(obj.data) + str.offsets[i])

                if rot_arr.size == size_of(f32) do obj.rot2d = (^f32)(rot_ptr)
                else if rot_arr.size == size_of(f64) do obj.rot2d64 = (^f64)(rot_ptr)
                else do assert(rot_arr.size == size_of(f32) || rot_arr.size == size_of(f64))
            }
        }
    }

    return obj
}

_create_object_name :: proc(data: $T, name: string) -> ^Object(T) { return _create_object_all(data, name, nil) }
_create_object_arena :: proc(data: $T, arena: ^eau.Arena) -> ^Object(T) { return _create_object_all(data, "object", arena) }
_create_object_none :: proc(data: $T) -> ^Object(T) { return _create_object_arena(data, nil) }

delete_object :: proc(obj: ^Object($T)) {
    //if stop, ok := obj.tag_funcs.stop.?; ok do stop(obj)
    if stop := obj.tag_funcs.stop; stop != nil do stop.fn(obj, stop.ctx)

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


ObjectProc :: struct{
    fn: proc(rawptr, rawptr),
    ctx: rawptr,
}

wrap_object_proc :: proc($p: proc(^Object($T))) -> ObjectProc {
    //return proc(obj: rawptr) { p((^Object(T))(obj)) }
    return ObjectProc{
        fn = proc(obj: rawptr, ctx: rawptr) {
            (proc(^Object(T))(ctx)((^Object(T))(obj)))
        },
        ctx = rawptr(p),
    }
}


init_objects :: proc() {
    item: ^TypelessObj_LL = init_obj
    for item != nil {
        //if init, ok := (^Object(any))(item.obj).tag_funcs.init.?; ok do init(item.obj)
        if init := (^Object(any))(item.obj).tag_funcs.init; init != nil do init.fn(item.obj, init.ctx)
        item = item.next
    }
}

draw_objects :: proc() {
    item: ^TypelessObj_LL = init_obj
    for item != nil {
        //if draw, ok := (^Object(any))(item.obj).tag_funcs.draw.?; ok do draw(item.obj)
        if draw := (^Object(any))(item.obj).tag_funcs.draw; draw != nil do draw.fn(item.obj, draw.ctx)
        item = item.next
    }
}

update_objects :: proc() {
    item: ^TypelessObj_LL = init_obj
    for item != nil {
        //if update, ok := (^Object(any))(item.obj).tag_funcs.update.?; ok do update(item.obj)
        if up := (^Object(any))(item.obj).tag_funcs.update; up != nil do up.fn(item.obj, up.ctx)
        item = item.next
    }
}

/*stop_objects :: proc() {
    item: ^TypelessObj_LL = init_obj
    for item != nil {
        if stop, ok := (^Object(any))(item.obj).tag_funcs.stop.?; ok do stop(item.obj)
        item = item.next
    }
}*/
